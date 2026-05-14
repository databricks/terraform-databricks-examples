locals {
  databricks_managed = var.vpc_source == "databricks_managed"
  create_vpc         = var.vpc_source == "create"
  use_existing_vpc   = var.vpc_source == "existing"

  any_private_link = var.private_link_frontend || var.private_link_backend
  spoke_project    = coalesce(var.spoke_vpc_google_project, var.google_project)
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false

  lifecycle {
    ignore_changes = [special, upper]
  }
}

# Cross-variable preconditions.
resource "null_resource" "preconditions" {
  lifecycle {
    precondition {
      condition     = !var.restricted_egress || local.create_vpc
      error_message = "restricted_egress=true requires vpc_source=\"create\" (hub-spoke topology needs us to own both VPCs)."
    }
    precondition {
      condition     = !var.restricted_egress || local.any_private_link
      error_message = "restricted_egress=true requires at least one of private_link_frontend or private_link_backend."
    }
    precondition {
      condition     = !var.restricted_egress || (var.hub_vpc_google_project != null && var.hub_vpc_cidr != null && var.psc_subnet_cidr != null)
      error_message = "restricted_egress=true requires hub_vpc_google_project, hub_vpc_cidr, and psc_subnet_cidr."
    }
    precondition {
      condition     = !local.create_vpc || (var.spoke_vpc_cidr != null && var.subnet_cidr != null)
      error_message = "vpc_source=\"create\" requires spoke_vpc_cidr and subnet_cidr."
    }
    precondition {
      condition     = !local.use_existing_vpc || (var.existing_vpc_name != null && var.existing_subnet_name != null)
      error_message = "vpc_source=\"existing\" requires existing_vpc_name and existing_subnet_name."
    }
    precondition {
      condition     = !local.databricks_managed || (!var.private_link_frontend && !var.private_link_backend && !var.restricted_egress)
      error_message = "vpc_source=\"databricks_managed\" forbids private_link_frontend, private_link_backend, and restricted_egress."
    }
  }
}

module "network" {
  source = "../network"
  count  = local.databricks_managed ? 0 : 1

  prefix                   = var.prefix
  suffix                   = random_string.suffix.result
  google_region            = var.google_region
  vpc_source               = var.vpc_source
  spoke_vpc_google_project = local.spoke_project

  spoke_vpc_cidr = var.spoke_vpc_cidr
  subnet_cidr    = var.subnet_cidr
  pod_cidr       = var.pod_cidr
  svc_cidr       = var.svc_cidr

  existing_vpc_name    = var.existing_vpc_name
  existing_subnet_name = var.existing_subnet_name

  create_hub               = var.restricted_egress
  hub_vpc_google_project   = var.hub_vpc_google_project
  hub_vpc_cidr             = var.hub_vpc_cidr
  is_spoke_vpc_shared      = var.is_spoke_vpc_shared
  workspace_google_project = var.google_project
}

module "private_connectivity" {
  source = "../private-connectivity"
  count  = local.any_private_link ? 1 : 0

  prefix        = var.prefix
  suffix        = random_string.suffix.result
  google_region = var.google_region

  spoke_vpc_id             = module.network[0].spoke_vpc_id
  spoke_vpc_self_link      = module.network[0].spoke_vpc_self_link
  spoke_vpc_google_project = local.spoke_project
  spoke_vpc_cidr           = var.spoke_vpc_cidr

  hub_vpc_id             = var.restricted_egress ? module.network[0].hub_vpc_id : null
  hub_vpc_self_link      = var.restricted_egress ? module.network[0].hub_vpc_self_link : null
  hub_vpc_google_project = var.hub_vpc_google_project
  hub_subnet_name        = var.restricted_egress ? module.network[0].hub_subnet_name : null
  hub_vpc_cidr           = var.hub_vpc_cidr

  enable_frontend = var.private_link_frontend
  enable_backend  = var.private_link_backend
  restrict_egress = var.restricted_egress
  psc_subnet_cidr = var.psc_subnet_cidr

  hive_metastore_ip = var.hive_metastore_ip
}

module "account" {
  source = "../account"

  prefix                = var.prefix
  suffix                = random_string.suffix.result
  workspace_name        = var.workspace_name
  databricks_account_id = var.databricks_account_id
  google_project        = var.google_project
  google_region         = var.google_region
  vpc_source            = var.vpc_source

  spoke_vpc_name           = local.databricks_managed ? null : module.network[0].spoke_vpc_name
  spoke_subnet_name        = local.databricks_managed ? null : module.network[0].spoke_subnet_name
  spoke_vpc_google_project = local.spoke_project
  hub_vpc_google_project   = var.hub_vpc_google_project

  frontend_psc_fr_id     = local.any_private_link ? module.private_connectivity[0].frontend_psc_fr_id : null
  backend_psc_fr_id      = local.any_private_link ? module.private_connectivity[0].backend_psc_fr_id : null
  hub_frontend_psc_fr_id = local.any_private_link ? module.private_connectivity[0].hub_frontend_psc_fr_id : null

  enable_frontend     = var.private_link_frontend
  enable_backend      = var.private_link_backend
  private_access_only = var.private_access_only

  nat_dependency = local.databricks_managed ? null : module.network[0].nat_id
}

module "dns" {
  source = "../dns"
  count  = var.restricted_egress ? 1 : 0

  prefix        = var.prefix
  google_region = var.google_region

  hub_vpc_id             = module.network[0].hub_vpc_id
  hub_vpc_self_link      = module.network[0].hub_vpc_self_link
  hub_vpc_google_project = var.hub_vpc_google_project

  spoke_vpc_id             = module.network[0].spoke_vpc_id
  spoke_vpc_self_link      = module.network[0].spoke_vpc_self_link
  spoke_vpc_google_project = local.spoke_project

  workspace_url = module.account.workspace_url

  frontend_psc_ip_spoke = module.private_connectivity[0].frontend_psc_ip_spoke
  frontend_psc_ip_hub   = module.private_connectivity[0].frontend_psc_ip_hub
  backend_psc_ip_spoke  = module.private_connectivity[0].backend_psc_ip_spoke
}
