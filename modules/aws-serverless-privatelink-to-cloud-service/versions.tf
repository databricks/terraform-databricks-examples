terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.10"
    }

    databricks = {
      source                = "databricks/databricks"
      version               = "~> 1.84"
      configuration_aliases = [databricks.mws]
    }
  }
}