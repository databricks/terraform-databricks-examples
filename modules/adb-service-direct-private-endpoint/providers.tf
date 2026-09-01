# We strongly recommend using the required_providers block to set the
# provider sources and versions being used
terraform {
  required_providers {
    # Specify the Azure Provider and its source
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.31.0"
    }

    # Specify the Databricks Provider and its source.
    # NOTE: databricks_endpoint (Public Preview) was added in v1.107.0 and is
    # required by this module — do not lower this floor.
    databricks = {
      source  = "databricks/databricks"
      version = ">=1.107.0"
    }

    # Specify the AzAPI Provider and its source. Used to read the private
    # endpoint's properties.resourceGuid, which azurerm does not export but
    # databricks_endpoint requires.
    azapi = {
      source  = "Azure/azapi"
      version = "2.0.1"
    }

    # Used for a short settle delay between PE creation and account-side
    # registration.
    time = {
      source  = "hashicorp/time"
      version = ">=0.9.0"
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

# Configure the Databricks Provider for account-level operations.
# databricks_endpoint can only be used with an account-level provider.
provider "databricks" {
  # Create an alias to differentiate this instance from any workspace provider
  alias = "accounts"

  # Account console host (Azure: https://accounts.azuredatabricks.net)
  host = var.databricks_host

  # Databricks account ID for authentication
  account_id = var.databricks_account_id
}

# Configure the AzAPI Provider for Azure resources
provider "azapi" {
  # Subscription ID for Azure authentication
  subscription_id = var.azure_subscription_id
}
