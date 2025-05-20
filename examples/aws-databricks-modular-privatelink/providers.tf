terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.93.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = "1.70.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.9.1"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "databricks" {
  alias         = "mws"
  host          = "https://accounts.cloud.databricks.com"
  account_id    = var.databricks_account_id
  client_id     = var.client_id
  client_secret = var.client_secret
}

provider "time" {
}
