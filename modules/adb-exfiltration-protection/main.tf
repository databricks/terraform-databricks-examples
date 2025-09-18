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

resource "azurerm_resource_group" "this" {
  count    = var.create_resource_group ? 1 : 0
  name     = "adb-dev-${local.prefix}-rg"
  location = local.location
  tags     = local.tags
}

data "azurerm_resource_group" "this" {
  count = var.create_resource_group ? 0 : 1
  name  = var.existing_resource_group_name
}

locals {
  // dltp - databricks labs terraform provider
  prefix   = join("-", [var.workspace_prefix, random_string.naming.result])
  location = var.rglocation
  cidr     = var.spokecidr
  dbfsname = join("", [var.dbfs_prefix, random_string.naming.result]) // dbfs name must not have special chars

  // tags that are propagated down to all resources
  tags = merge({
    Environment = "Testing"
    Owner       = lookup(data.external.me.result, "name")
    Epoch       = random_string.naming.result
  }, var.tags)

  rg_name     = var.create_resource_group ? azurerm_resource_group.this[0].name : data.azurerm_resource_group.this[0].name
  rg_id       = var.create_resource_group ? azurerm_resource_group.this[0].id : data.azurerm_resource_group.this[0].id
  rg_location = var.create_resource_group ? azurerm_resource_group.this[0].location : (var.rglocation == "" ? data.azurerm_resource_group.this[0].location : var.rglocation)
}