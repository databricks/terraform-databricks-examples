terraform {

  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.0.0"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}
