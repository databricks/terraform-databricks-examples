terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }

    databricks = {
      source = "databricks/databricks"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

provider "databricks" {
  alias = "adb-ow-main-ws"
  host = module.adb-overwatch-main-ws.adb_ow_main_ws_url
}