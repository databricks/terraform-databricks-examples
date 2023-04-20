terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "=4.57.0"
    }

    databricks = {
      source                = "databricks/databricks"
      version               = ">=1.9.2"
      configuration_aliases = [databricks.mws]
    }
  }
}