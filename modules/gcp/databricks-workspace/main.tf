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
  create_hub      = var.restricted_egress
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

  frontend_forwarding_rule_name     = local.any_private_link ? module.private_connectivity[0].frontend_forwarding_rule_name : null
  backend_forwarding_rule_name      = local.any_private_link ? module.private_connectivity[0].backend_forwarding_rule_name : null
  hub_frontend_forwarding_rule_name = local.any_private_link ? module.private_connectivity[0].hub_frontend_forwarding_rule_name : null

  enable_frontend     = var.private_link_frontend
  enable_backend      = var.private_link_backend
  private_access_only = var.private_access_only
  create_hub          = var.restricted_egress

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
