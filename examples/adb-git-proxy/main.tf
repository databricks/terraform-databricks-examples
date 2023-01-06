# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = ">=0.5.1"
    }
  }
}

resource "random_string" "naming" {
  special = false
  upper   = false
  length  = 6
}

resource "azurerm_resource_group" "example" {
  name     = "databricks-demo-${random_string.naming.result}-rg"
  location = var.rglocation
}

locals {
  // dltp - databricks labs terraform provider
  prefix   = join("-", [var.workspace_prefix, "${random_string.naming.result}"])
  location = var.rglocation
  dbfsname = join("", [var.dbfs_prefix, "${random_string.naming.result}"]) // dbfs name must not have special chars

  // tags that are propagated down to all resources
  tags = {
    Environment = "Testing"
  }
}
