terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.31.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "2.0.1"
    }
    databricks = {
      source  = "databricks/databricks"
      version = ">=1.81.1"
    }
    null = {
      source  = "hashicorp/null"
      version = ">=3.2.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">=0.9.0"
    }
  }
}
