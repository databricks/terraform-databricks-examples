terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.region
}

// initialize provider in "MWS" mode to provision new workspace
provider "databricks" {
  alias      = "mws"
  host       = "https://accounts.cloud.databricks.com"
  account_id = var.databricks_account_id   // like a shared account? HA from multiple email accounts
  username   = var.databricks_account_username
  password   = var.databricks_account_password
  auth_type  = "basic"
}

provider "databricks" {
  alias = "ws1"
  host  = "https://dbc-167215e3-dd0f.cloud.databricks.com"
  token = var.pat_ws_1
}

provider "databricks" {
  alias = "ws2"
  host  = "https://dbc-dc6a79a6-893f.cloud.databricks.com"
  token = var.pat_ws_2
}
