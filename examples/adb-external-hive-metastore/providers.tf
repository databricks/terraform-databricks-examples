terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = ">=1.27.0"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.76.0"
    }
  }
}

provider "random" {
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

# Use Azure CLI to authenticate at Azure Databricks account level, and the Azure Databricks workspace level
provider "databricks" {
  host = azurerm_databricks_workspace.this.workspace_url
}
