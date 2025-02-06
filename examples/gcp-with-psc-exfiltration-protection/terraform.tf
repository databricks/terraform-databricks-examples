terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
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