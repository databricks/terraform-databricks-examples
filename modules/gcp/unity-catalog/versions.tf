terraform {
  required_version = ">= 1.5"
  required_providers {
    databricks = {
      source                = "databricks/databricks"
      configuration_aliases = [databricks, databricks.workspace]
      version               = ">= 1.81.1"
    }
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }
}
