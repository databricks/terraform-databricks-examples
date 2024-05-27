/**
 * Azure Databricks workspace in custom VNet
 *
 * Module creates:
 * * Resource group with random prefix
 * * Tags, including `Owner`, which is taken from `az account show --query user`
 * * VNet with public and private subnet
 * * Databricks workspace
 */

resource "random_string" "naming" {
  special = false
  upper   = false
  length  = 6
}

data "azurerm_client_config" "current" {
}

data "external" "me" {
  program = ["az", "account", "show", "--query", "user"]
}

locals {
  // dltp - databricks labs terraform provider
  prefix   = join("-", [var.workspace_prefix, "${random_string.naming.result}"])
  location = var.rglocation
  cidr     = var.spokecidr
  dbfsname = join("", [var.dbfs_prefix, "${random_string.naming.result}"]) // dbfs name must not have special chars

  // tags that are propagated down to all resources
  tags = merge({
    Owner = lookup(data.external.me.result, "name")
    Epoch = random_string.naming.result
  }, var.tags)
}

resource "azurerm_resource_group" "this" {
  name     = "adb-dev-${local.prefix}-rg"
  location = local.location
  tags     = local.tags
}
