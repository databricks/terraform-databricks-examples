terraform {
  required_version = ">= 1.5"
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.81"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 6.17"
    }
  }
}
