# versions.tf
terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "0.3.10"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.83.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = ">= 3.1"
    }
  }
}
