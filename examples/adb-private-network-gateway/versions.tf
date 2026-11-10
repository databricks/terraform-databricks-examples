terraform {
  required_version = ">= 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0, < 5.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = ">= 1.140.0"
    }
  }
}
