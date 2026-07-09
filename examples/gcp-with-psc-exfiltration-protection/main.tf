module "workspace" {
  source = "../../modules/gcp/databricks-workspace"

  prefix                = var.prefix
  databricks_account_id = var.databricks_account_id
  google_project        = var.workspace_google_project
  google_region         = var.google_region

  vpc_source     = { spoke = "create", hub = "create" }
  spoke_vpc_cidr = var.spoke_vpc_cidr
  subnet_cidr    = var.subnet_cidr

  private_link_frontend = true
  private_link_backend  = true
  private_access_only   = true
  restricted_egress     = true

  spoke_vpc_google_project = var.spoke_vpc_google_project
  hub_vpc_google_project   = var.hub_vpc_google_project
  is_spoke_vpc_shared      = var.is_spoke_vpc_shared
  hub_vpc_cidr             = var.hub_vpc_cidr
  psc_subnet_cidr          = var.psc_subnet_cidr
  hive_metastore_ip        = var.hive_metastore_ip

  serverless_egress_mode                   = var.serverless_egress_mode
  serverless_allowed_internet_destinations = var.serverless_allowed_internet_destinations
  serverless_allowed_storage_destinations  = var.serverless_allowed_storage_destinations
  serverless_egress_enforcement            = var.serverless_egress_enforcement

  cmek_managed_services_key_id = var.cmek_managed_services_key_id
  cmek_storage_key_id          = var.cmek_storage_key_id
}