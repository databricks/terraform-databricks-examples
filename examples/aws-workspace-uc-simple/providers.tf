provider "aws" {
  region  = var.region
  profile = var.aws_profile
}

// Initialize provider in multi workspace mode
provider "databricks" {
  alias         = "mws"
  host          = "https://accounts.cloud.databricks.com"
  account_id    = var.databricks_account_id
  client_id     = var.databricks_client_id
  client_secret = var.databricks_client_secret
}

# Initialize the provider for the workspace we created in this terraform
provider "databricks" {
  alias         = "workspace"
  host          = module.databricks_workspace.databricks_host
  client_id     = var.databricks_client_id
  client_secret = var.databricks_client_secret
}
