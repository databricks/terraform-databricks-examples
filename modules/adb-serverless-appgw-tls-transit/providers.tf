# We strongly recommend using the required_providers block to set the
# provider sources and versions being used
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
    # azapi is required because the azurerm provider does not expose the
    # Application Gateway v2 TCP/TLS listener configuration.
    azapi = {
      source  = "Azure/azapi"
      version = "2.0.1"
    }
    # null + time drive the REST-based NCC private endpoint rule (the documented
    # Application Gateway method — see README) and its propagation wait.
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

# Configure the Microsoft Azure Provider
provider "azurerm" {
  subscription_id = var.azure_subscription_id
  features {}
}

# Account-level Databricks provider (required for NCC resources).
provider "databricks" {
  alias      = "accounts"
  host       = var.databricks_host
  account_id = var.databricks_account_id
}

# AzAPI provider for the Application Gateway v2 TCP listener.
provider "azapi" {
  subscription_id = var.azure_subscription_id
}
