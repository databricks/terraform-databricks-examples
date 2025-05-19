locals {
  service_delegation_actions = [
    "Microsoft.Network/virtualNetworks/subnets/join/action",
    "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
    "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
  ]

  managed_resource_group_name = var.managed_resource_group_name == "" ? "${var.databricks_workspace_name}-managed-rg" : var.managed_resource_group_name
}

resource "azurerm_subnet" "private" {
  name                 = "private-subnet-${var.databricks_workspace_name}"
  resource_group_name  = local.rg_name
  virtual_network_name = azurerm_virtual_network.this.name

  address_prefixes = var.private_subnet_address_prefixes

  service_endpoints = var.service_endpoints

  delegation {
    name = "databricks-private-subnet-delegation"

    service_delegation {
      name    = "Microsoft.Databricks/workspaces"
      actions = local.service_delegation_actions
    }
  }
}

resource "azurerm_subnet" "public" {
  name                 = "public-subnet-${var.databricks_workspace_name}"
  resource_group_name  = local.rg_name
  virtual_network_name = azurerm_virtual_network.this.name

  address_prefixes = var.public_subnet_address_prefixes

  service_endpoints = var.service_endpoints

  delegation {
    name = "databricks-public-subnet-delegation"

    service_delegation {
      name    = "Microsoft.Databricks/workspaces"
      actions = local.service_delegation_actions
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "private" {
  subnet_id                 = azurerm_subnet.private.id
  network_security_group_id = azurerm_network_security_group.this.id
}

resource "azurerm_subnet_network_security_group_association" "public" {
  subnet_id                 = azurerm_subnet.public.id
  network_security_group_id = azurerm_network_security_group.this.id
}

resource "azurerm_subnet_route_table_association" "private" {
  count = var.create_nat_gateway ? 0 : 1

  subnet_id      = azurerm_subnet.private.id
  route_table_id = azurerm_route_table.this[0].id
}

resource "azurerm_subnet_route_table_association" "public" {
  count = var.create_nat_gateway ? 0 : 1

  subnet_id      = azurerm_subnet.public.id
  route_table_id = azurerm_route_table.this[0].id
}

resource "azurerm_subnet_nat_gateway_association" "public" {
  count = var.create_nat_gateway ? 1 : 0

  subnet_id      = azurerm_subnet.public.id
  nat_gateway_id = azurerm_nat_gateway.this[0].id
}

resource "azurerm_databricks_workspace" "this" {
  name                        = var.databricks_workspace_name
  resource_group_name         = local.rg_name
  managed_resource_group_name = local.managed_resource_group_name
  location                    = local.rg_location
  sku                         = "premium"

  custom_parameters {
    virtual_network_id                                   = azurerm_virtual_network.this.id
    private_subnet_name                                  = azurerm_subnet.private.name
    public_subnet_name                                   = azurerm_subnet.public.name
    private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.private.id
    public_subnet_network_security_group_association_id  = azurerm_subnet_network_security_group_association.public.id
  }

  tags = var.tags
}
