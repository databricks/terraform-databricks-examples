resource "azurerm_resource_group" "this" {
  name     = var.spoke_resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "this" {
  name                = "VNET-${var.project_name}-${var.environment_name}"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = [var.spoke_vnet_address_space]
  tags                = var.tags
}

resource "azurerm_network_security_group" "this" {
  name                = "databricks-nsg-${var.project_name}-${var.environment_name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = var.tags
}


resource "azurerm_route_table" "this" {
  name                = "route-table-${var.project_name}-${var.environment_name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = var.tags
}
