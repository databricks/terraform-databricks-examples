# versions.tf
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.40.0"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}
