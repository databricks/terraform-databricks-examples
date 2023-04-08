terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.13.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "1.1.0"
    }
  }
}
