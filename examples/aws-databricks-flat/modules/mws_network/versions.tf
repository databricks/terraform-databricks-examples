terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
  }
}

provider "aws" {
  region  = var.region
  version = "~> 4.0"
}

// initialize provider in "MWS" mode to provision new workspace
provider "databricks" {
  alias         = "mws"
  host          = "https://accounts.cloud.databricks.com"
  client_id     = var.databricks_account_client_id
  client_secret = var.databricks_account_client_secret
  account_id    = var.databricks_account_id
}
