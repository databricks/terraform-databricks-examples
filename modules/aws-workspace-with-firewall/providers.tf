provider "aws" {
  region = var.region
}

// initialize provider in "MWS" mode to provision new workspace
provider "databricks" {
  alias         = "mws"
  host          = "https://accounts.cloud.databricks.com"
  username      = var.databricks_account_username
  password      = var.databricks_account_password
  client_id     = var.databricks_account_client_id
  client_secret = var.databricks_account_client_secret
}
