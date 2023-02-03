terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.30.0"
    }
  }
}

provider "azuread" {
}

provider "azurerm" {
  features {}
}
