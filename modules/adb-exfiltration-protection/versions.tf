# versions.tf
terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = ">=1.20.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.83.0"
    }
    random = {
      source = "hashicorp/random"
    }
    dns = {
      source = "hashicorp/dns"
    }
  }
}
