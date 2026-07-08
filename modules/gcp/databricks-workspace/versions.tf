terraform {
  required_version = ">= 1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = ">= 1.81.1"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }
}
