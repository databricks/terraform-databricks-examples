# versions.tf
terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = ">=1.13.0"
    }

    aws = {
      source  = "hashicorp/aws"
      version = ">=5.38.0"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "databricks" {
  host = "https://accounts.cloud.databricks.com"
}