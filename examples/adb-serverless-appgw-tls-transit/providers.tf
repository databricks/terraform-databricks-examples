terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.31.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = ">=1.81.1"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "2.0.1"
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

provider "azurerm" {
  subscription_id = var.azure_subscription_id
  features {}
}

provider "databricks" {
  alias      = "accounts"
  host       = var.databricks_host
  account_id = var.databricks_account_id
}

provider "azapi" {
  subscription_id = var.azure_subscription_id
}
