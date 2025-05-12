terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = ">=1.77.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "6.17.0"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}