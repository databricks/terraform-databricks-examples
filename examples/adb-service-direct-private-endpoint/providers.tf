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
      version = ">=1.107.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "2.0.1"
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

# Account-level provider — required by databricks_endpoint.
provider "databricks" {
  alias      = "accounts"
  host       = var.databricks_host
  account_id = var.databricks_account_id
}

provider "azapi" {
  subscription_id = var.azure_subscription_id
}
