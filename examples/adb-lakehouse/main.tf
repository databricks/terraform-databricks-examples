module "adb-lakehouse" {
  source                          = "../../modules/adb-lakehouse"
  project_name                    = var.project_name
  environment_name                = var.environment_name
  location                        = var.location
  spoke_vnet_address_space        = var.spoke_vnet_address_space
  spoke_resource_group_name       = var.spoke_resource_group_name
  databricks_workspace_name       = var.databricks_workspace_name
  data_factory_name               = var.data_factory_name
  key_vault_name                  = var.key_vault_name
  private_subnet_address_prefixes = var.private_subnet_address_prefixes
  public_subnet_address_prefixes  = var.public_subnet_address_prefixes
  storage_account_names           = var.storage_account_names
  tags                            = var.tags
  shared_resource_group_name      = var.shared_resource_group_name
  metastore_storage_name          = var.metastore_storage_name
  access_connector_name           = var.access_connector_name
}

module "adb-lakehouse-uc-account-api" {
  depends_on                      = [module.adb-lakehouse]
  source                          = "../../modules/adb-lakehouse-uc/uc-account-api"
  access_connector_id             = var.access_connector_id
  metastore_name                  = var.metastore_name
  metastore_storage_name          = var.metastore_storage_name
  access_connector_name           = var.access_connector_name
  metastore_id                    = var.metastore_id
  workspace_id                    = var.workspace_id
  service_principals              = var.service_principals
  account_groups                  = var.account_groups
  storage_credential_id           = var.storage_credential_id
  providers = {
    databricks = databricks.account
  }
}

module "adb-lakehouse-uc-workspace-api" {
  depends_on                      = [module.adb-lakehouse-uc-account-api]
  source                          = "../../modules/adb-lakehouse-uc/uc-workspace-api"
  environment_name                = var.environment_name
  storage_credential_id           = var.storage_credential_id
  metastore_id                    = var.metastore_id
  landing_external_location_name  = var.landing_external_location_name
  landing_adls_path               = var.landing_adls_path
  metastore_admins                = var.metastore_admins
  providers = {
    databricks = databricks.workspace
  }
}