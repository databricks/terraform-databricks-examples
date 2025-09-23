resource "random_string" "naming" {
  special = false
  upper   = false
  length  = 6
}

resource "azurerm_resource_group" "this" {
  count    = var.create_resource_group ? 1 : 0
  name     = "${local.prefix}-rg"
  location = local.location
  tags     = local.tags
}

data "azurerm_resource_group" "this" {
  count = var.create_resource_group ? 0 : 1
  name  = var.existing_resource_group_name

}

locals {
  prefix   = join("-", [var.workspace_prefix, "${random_string.naming.result}"])
  location = var.rglocation
  dbfsname = join("", [var.dbfs_prefix, "${random_string.naming.result}"]) // dbfs name must not have special chars

  tags = {
    Environment = "Testing"
    Owner       = lookup(data.external.me.result, "name")
    Epoch       = random_string.naming.result
  }

  rg_name     = var.create_resource_group ? azurerm_resource_group.this[0].name : data.azurerm_resource_group.this[0].name
  rg_id       = var.create_resource_group ? azurerm_resource_group.this[0].id : data.azurerm_resource_group.this[0].id
  rg_location = var.create_resource_group ? azurerm_resource_group.this[0].location : (var.rglocation == "" ? data.azurerm_resource_group.this[0].location : var.rglocation)
}

module "kafka_broker" {
  source              = "./modules/general_vm"
  resource_group_name = local.rg_name
  vm_name             = "broker01"
  region              = local.location
  subnet_id           = azurerm_subnet.vm_subnet.id

}
