resource "random_string" "naming" {
  special = false
  upper   = false
  length  = 6
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
}

resource "azurerm_resource_group" "this" {
  name     = "adb-${local.prefix}-rg"
  location = local.location
  tags     = local.tags
}

module "kafka_broker" {
  source              = "./modules/general_vm"
  resource_group_name = azurerm_resource_group.this.name
  vm_name             = "broker01"
  region              = local.location
  subnet_id           = azurerm_subnet.vm_subnet.id
}
