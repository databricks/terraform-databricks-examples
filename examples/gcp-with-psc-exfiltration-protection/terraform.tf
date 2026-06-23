terraform {
  required_version = ">= 1.9.0"

  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = ">=1.85.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 6.45"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}