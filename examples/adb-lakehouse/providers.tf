terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.13.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = "1.6.5"
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

#authenticating using AD service principal secret by setting the env variable ARM_CLIENT_SECRET
provider "databricks" {
  alias      = "account"
  host       = "https://accounts.azuredatabricks.net"
  account_id = "<account_id>"
}

#authenticating using AD service principal secret by setting the env variable ARM_CLIENT_SECRET
provider "databricks" {
  alias = "workspace"
  host  = "<workspace_url>"
}