terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">=3.3.2"
    }
    local = {
      source  = "hashicorp/local"
      version = ">=2.2.3"
    }
  }
}

resource "random_string" "naming" {
  special = false
  upper   = false
  length  = 6
}

locals {
  storage_account_name = join("", ["adls", "${random_string.naming.result}"]) // must not have special chars
}

resource "azurerm_storage_account" "personaldropbox" {
  name                     = local.storage_account_name
  resource_group_name      = var.rg
  location                 = var.storage_account_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "example_container" {
  name                  = "cnt1"
  storage_account_name  = azurerm_storage_account.personaldropbox.name
  container_access_type = "container" // for anonymous read container from public
}
