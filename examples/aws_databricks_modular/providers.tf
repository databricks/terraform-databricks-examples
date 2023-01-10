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
  // provider configuration
  region = var.region
}

// initialize provider in "MWS" mode to provision new workspace
provider "databricks" {
  alias     = "mws"
  host      = "https://accounts.cloud.databricks.com"
  username  = var.databricks_account_username
  password  = var.databricks_account_password
  auth_type = "basic"
}

// initialize provider in normal mode
/*
provider "databricks" {
  // in normal scenario you won't have to give providers aliases
  alias = "created_workspace"
  host  = module.workspace1.workspace_url
}
*/
