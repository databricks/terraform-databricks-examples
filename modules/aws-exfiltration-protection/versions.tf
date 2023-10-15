# versions.tf
terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = ">=1.27.0"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.20.1"
    }
  }
}
