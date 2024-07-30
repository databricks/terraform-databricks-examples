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
  account_id    = var.databricks_account_id
  client_id     = var.databricks_account_client_id
  client_secret = var.databricks_account_client_secret
}

// initialize provider in normal mode
provider "databricks" {
  // in normal scenario you won't have to give providers aliases
  alias = "created_workspace"
  host  = databricks_mws_workspaces.this.workspace_url
}
