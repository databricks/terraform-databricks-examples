# versions.tf
terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = ">=1.13.0"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.83.0"
    }
  }
}
