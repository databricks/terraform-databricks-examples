# versions.tf
terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = ">=0.5.1"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.58.0"
    }
  }
}
