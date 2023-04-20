provider "aws" {
  region  = var.region
  profile = var.aws_profile
}

// initialize provider in normal mode
provider "databricks" {
  alias      = "mws"
  account_id = var.databricks_account_id
  host       = "https://accounts.cloud.databricks.com"
  username   = var.databricks_account_username
  password   = var.databricks_account_password
}

provider "databricks" {
  alias = "workspace"
  host  = module.databricks_workspace.databricks_host
  token = module.databricks_workspace.databricks_token
}
