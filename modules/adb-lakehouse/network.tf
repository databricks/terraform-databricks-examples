resource "azurerm_virtual_network" "this" {
  name                = "VNET-${var.project_name}-${var.environment_name}"
  location            = local.rg_location
  resource_group_name = local.rg_name
  address_space       = [var.spoke_vnet_address_space]
  tags                = var.tags
}

resource "azurerm_network_security_group" "this" {
  name                = "databricks-nsg-${var.project_name}-${var.environment_name}"
  location            = local.rg_location
  resource_group_name = local.rg_name
  tags                = var.tags
}


resource "azurerm_route_table" "this" {
  name                = "route-table-${var.project_name}-${var.environment_name}"
  location            = local.rg_location
  resource_group_name = local.rg_name
  tags                = var.tags
}
