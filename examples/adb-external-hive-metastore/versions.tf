# versions.tf
terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = ">=1.14"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.54.0"
    }
  }
}
