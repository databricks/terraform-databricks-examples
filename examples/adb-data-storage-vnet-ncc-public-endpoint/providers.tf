# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    # Specify the Azure Provider and its source
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">=4.31.0"
    }
    
    # Specify the Databricks Provider and its source
    databricks = {
      source = "databricks/databricks"
      version = ">=1.81.1"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  # Subscription ID for Azure authentication
  subscription_id = var.azure_subscription_id

  # Enable features for the Azure Provider
  features {}
  
}

# Configure the Databricks Provider for account-level operations
provider "databricks" {
  # Create an alias for this provider instance to differentiate it from others
  alias         = "accounts"
  
  # Host URL for the Databricks workspace or account
  host          = var.databricks_host
  
  # Databricks account ID for authentication
  account_id    = var.databricks_account_id
  
}

# Configure the Databricks Provider for workspace-level operations
provider "databricks" {
  # Create an alias for this provider instance to differentiate it from others
  alias         = "workspace"
  
  # Host URL for the Databricks workspace
  host          = azurerm_databricks_workspace.this.workspace_url
  
}

