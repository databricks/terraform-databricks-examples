resource "databricks_mws_workspaces" "this" {
  provider       = databricks.mws
  account_id     = var.databricks_account_id
  aws_region     = var.region
  workspace_name = local.prefix
  # deployment_name = local.prefix

  credentials_id           = databricks_mws_credentials.this.credentials_id
  storage_configuration_id = databricks_mws_storage_configurations.this.storage_configuration_id
  network_id               = module.my_mws_network.network_id
}

// create PAT token to provision entities within workspace
resource "databricks_token" "pat" {
  provider         = databricks.created_workspace
  comment          = "Terraform Provisioning"
  lifetime_seconds = 86400
}
