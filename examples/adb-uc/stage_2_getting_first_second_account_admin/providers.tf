terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    databricks = {
      source = "databricks/databricks"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.30.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {
  # Configuration options
}

provider "databricks" { // TF account level endpoint
  alias      = "azure_account"
  host       = "https://accounts.azuredatabricks.net"
  account_id = "f3b0d159-720f-4d2e-bdc4-18104f13f419" // Databricks will provide
  auth_type  = "azure-cli"                            // az login with SPN
}
