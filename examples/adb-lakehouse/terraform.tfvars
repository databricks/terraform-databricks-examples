subscription_id = "<your Azure Subscription ID here>"
account_id      = "<your Databricks Account ID here>"

location                        = "ukwest"
existing_resource_group_name    = "db_lh_example_rg"
project_name                    = "db_lh_example"
environment_name                = "db_lh_example_env"
databricks_workspace_name       = "db_lh_example_ws"
spoke_vnet_address_space        = "10.178.0.0/16"
private_subnet_address_prefixes = ["10.178.0.0/20"]
public_subnet_address_prefixes  = ["10.178.16.0/20"]
shared_resource_group_name      = "db_lh_example_shared_rg"
metastore_name                  = "db_lh_metastore"
metastore_storage_name          = "dblhmetastorestorage"
access_connector_name           = "db_lh_example_connector"
landing_external_location_name  = "dblhexamplelanding"
landing_adls_path               = "abfss://example@dblhexamplelanding.dfs.core.windows.net"
landing_adls_rg                 = "dblhexamplelanding"
metastore_admins                = ["<your email here>"]

tags = {
  Owner = "<your email here>"
}