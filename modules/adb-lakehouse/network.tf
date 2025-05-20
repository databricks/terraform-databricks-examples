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
  count = var.create_nat_gateway ? 0 : 1

  name                = "route-table-${var.project_name}-${var.environment_name}"
  location            = local.rg_location
  resource_group_name = local.rg_name
  tags                = var.tags
}

resource "azurerm_nat_gateway" "this" {
  count = var.create_nat_gateway ? 1 : 0

  name                = "nat-gateway-${var.project_name}-${var.environment_name}"
  location            = local.rg_location
  resource_group_name = local.rg_name
  tags                = var.tags
}

resource "azurerm_public_ip" "this" {
  count = var.create_nat_gateway ? 1 : 0

  name                = "nat-gateway-pip-${var.project_name}-${var.environment_name}"
  location            = local.rg_location
  resource_group_name = local.rg_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_nat_gateway_public_ip_association" "this" {
  count = var.create_nat_gateway ? 1 : 0

  nat_gateway_id       = azurerm_nat_gateway.this[0].id
  public_ip_address_id = azurerm_public_ip.this[0].id
}
