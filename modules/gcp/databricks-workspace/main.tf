module "network" {
  source = "../network"
  count  = local.databricks_managed ? 0 : 1

  prefix                   = var.prefix
  suffix                   = random_string.suffix.result
  google_region            = var.google_region
  vpc_source               = var.vpc_source.spoke
  spoke_vpc_google_project = local.spoke_project

  subnet_cidr = var.subnet_cidr

  existing_vpc_name    = var.existing_vpc_name
  existing_subnet_name = var.existing_subnet_name

  enable_hub               = var.restricted_egress
  enable_hub_spoke_peering = var.enable_hub_spoke_peering
  hub_vpc_source           = local.hub_source
  existing_hub_vpc_name    = var.existing_hub_vpc_name
  existing_hub_subnet_name = var.existing_hub_subnet_name
  hub_vpc_google_project   = var.hub_vpc_google_project
  hub_vpc_cidr             = var.hub_vpc_cidr
  is_spoke_vpc_shared      = var.is_spoke_vpc_shared
  workspace_google_project = var.google_project
  enable_nat               = !var.restricted_egress
}

module "private_connectivity" {
  source = "../private-connectivity"
  count  = local.private_connectivity_enabled ? 1 : 0

  prefix        = var.prefix
  suffix        = random_string.suffix.result
  google_region = var.google_region

  spoke_vpc_id             = local.databricks_managed ? null : module.network[0].spoke_vpc_id
  spoke_vpc_self_link      = local.databricks_managed ? null : module.network[0].spoke_vpc_self_link
  spoke_vpc_google_project = local.spoke_project
  spoke_vpc_cidr           = var.spoke_vpc_cidr

  hub_vpc_id             = var.restricted_egress ? module.network[0].hub_vpc_id : null
  hub_vpc_self_link      = var.restricted_egress ? module.network[0].hub_vpc_self_link : null
  hub_vpc_google_project = var.hub_vpc_google_project
  hub_subnet_name        = var.restricted_egress ? module.network[0].hub_subnet_name : null

  enable_frontend = var.private_link_frontend
  enable_backend  = var.private_link_backend
  restrict_egress = var.restricted_egress
  enable_hub      = var.restricted_egress
  psc_subnet_cidr = var.psc_subnet_cidr

  hive_metastore_ip = var.hive_metastore_ip
}

module "workspace" {
  source = "../workspace"

  prefix                = var.prefix
  suffix                = random_string.suffix.result
  workspace_name        = var.workspace_name
  databricks_account_id = var.databricks_account_id
  google_project        = var.google_project
  google_region         = var.google_region
  vpc_source            = var.vpc_source.spoke

  spoke_vpc_name           = local.databricks_managed ? null : module.network[0].spoke_vpc_name
  spoke_subnet_name        = local.databricks_managed ? null : module.network[0].spoke_subnet_name
  spoke_vpc_google_project = local.spoke_project
  hub_vpc_google_project   = var.hub_vpc_google_project

  frontend_forwarding_rule_name     = local.private_connectivity_enabled ? module.private_connectivity[0].frontend_forwarding_rule_name : null
  backend_forwarding_rule_name      = local.private_connectivity_enabled ? module.private_connectivity[0].backend_forwarding_rule_name : null
  hub_frontend_forwarding_rule_name = local.private_connectivity_enabled ? module.private_connectivity[0].hub_frontend_forwarding_rule_name : null

  enable_frontend     = var.private_link_frontend
  enable_backend      = var.private_link_backend
  private_access_only = var.private_access_only
  enable_hub          = var.restricted_egress

  nat_dependency = local.databricks_managed ? null : module.network[0].nat_id

  serverless_egress_mode                   = var.serverless_egress_mode
  serverless_allowed_internet_destinations = var.serverless_allowed_internet_destinations
  serverless_allowed_storage_destinations  = var.serverless_allowed_storage_destinations
  serverless_egress_enforcement            = var.serverless_egress_enforcement

  cmek_managed_services_key_id = var.cmek_managed_services_key_id
  cmek_storage_key_id          = var.cmek_storage_key_id
}

module "dns" {
  source = "../dns"
  count  = local.dns_enabled ? 1 : 0

  prefix        = var.prefix
  google_region = var.google_region

  hub_vpc_id             = local.databricks_managed ? null : module.network[0].hub_vpc_id
  hub_vpc_google_project = var.hub_vpc_google_project

  spoke_vpc_id             = local.databricks_managed ? null : module.network[0].spoke_vpc_id
  spoke_vpc_google_project = local.spoke_project

  workspace_url = module.workspace.workspace_url

  frontend_psc_ip_spoke = local.private_connectivity_enabled ? module.private_connectivity[0].frontend_psc_ip_spoke : null
  frontend_psc_ip_hub   = local.private_connectivity_enabled ? module.private_connectivity[0].frontend_psc_ip_hub : null
  backend_psc_ip_spoke  = local.private_connectivity_enabled ? module.private_connectivity[0].backend_psc_ip_spoke : null
}
