terraform {

  required_version = ">= 1.9.0"

  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = ">=1.52.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.0.0"
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

# This will be used to manage Azure Databricks workspace resources (Azure Databricks workspace itself is managed by `azurerm` provider)
provider "databricks" {
  host = azurerm_databricks_workspace.this.workspace_url
}
