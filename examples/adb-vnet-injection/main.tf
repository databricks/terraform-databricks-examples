resource "random_string" "naming" {
  special = false
  upper   = false
  length  = 6
}

locals {
  prefix   = join("-", [var.workspace_prefix, "${random_string.naming.result}"])
  location = var.rglocation
  dbfsname = join("", [var.dbfs_prefix, "${random_string.naming.result}"]) // dbfs name must not have special chars

  // tags that are propagated down to all resources
  tags = merge({
    Environment = "Testing"
    Epoch       = random_string.naming.result
  }, var.tags)

  rg_name     = var.create_resource_group ? azurerm_resource_group.this[0].name : data.azurerm_resource_group.this[0].name
  rg_id       = var.create_resource_group ? azurerm_resource_group.this[0].id : data.azurerm_resource_group.this[0].id
  rg_location = var.create_resource_group ? azurerm_resource_group.this[0].location : (var.rglocation == "" ? data.azurerm_resource_group.this[0].location : var.rglocation)
}

resource "azurerm_resource_group" "this" {
  count    = var.create_resource_group ? 1 : 0
  name     = "${local.prefix}-basic-demo-rg"
  location = local.location
  tags     = local.tags
}

data "azurerm_resource_group" "this" {
  count = var.create_resource_group ? 0 : 1
  name  = var.existing_resource_group_name
}


data "databricks_spark_version" "latest_lts" {
  long_term_support = true
  depends_on        = [azurerm_databricks_workspace.example]
}
