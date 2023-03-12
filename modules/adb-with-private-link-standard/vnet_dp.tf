resource "azurerm_virtual_network" "dp_vnet" {
  name                = "${local.prefix}-dp-vnet"
  location            = azurerm_resource_group.dp_rg.location
  resource_group_name = azurerm_resource_group.dp_rg.name
  address_space       = [var.cidr_dp]
  tags                = local.tags
}

resource "azurerm_network_security_group" "dp_sg" {
  name                = "${local.prefix}-dp-nsg"
  location            = azurerm_resource_group.dp_rg.location
  resource_group_name = azurerm_resource_group.dp_rg.name
  tags                = local.tags
}

resource "azurerm_network_security_rule" "dp_aad" {
  name                        = "AllowAAD-dp"
  priority                    = 200
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "AzureActiveDirectory"
  resource_group_name         = azurerm_resource_group.dp_rg.name
  network_security_group_name = azurerm_network_security_group.dp_sg.name
}

resource "azurerm_network_security_rule" "dp_azfrontdoor" {
  name                        = "AllowAzureFrontDoor-dp"
  priority                    = 201
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "AzureFrontDoor.Frontend"
  resource_group_name         = azurerm_resource_group.dp_rg.name
  network_security_group_name = azurerm_network_security_group.dp_sg.name
}

resource "azurerm_subnet" "dp_public" {
  name                 = "${local.prefix}-dp-public"
  resource_group_name  = azurerm_resource_group.dp_rg.name
  virtual_network_name = azurerm_virtual_network.dp_vnet.name
  address_prefixes     = [cidrsubnet(var.cidr_dp, 6, 0)]

  delegation {
    name = "databricks"
    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
      "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"]
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "dp_public" {
  subnet_id                 = azurerm_subnet.dp_public.id
  network_security_group_id = azurerm_network_security_group.dp_sg.id
}

variable "private_subnet_endpoints" {
  default = []
}

resource "azurerm_subnet" "dp_private" {
  name                 = "${local.prefix}-dp-private"
  resource_group_name  = azurerm_resource_group.dp_rg.name
  virtual_network_name = azurerm_virtual_network.dp_vnet.name
  address_prefixes     = [cidrsubnet(var.cidr_dp, 6, 1)]

  enforce_private_link_endpoint_network_policies = true
  enforce_private_link_service_network_policies  = true

  delegation {
    name = "databricks"
    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
      "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"]
    }
  }

  service_endpoints = var.private_subnet_endpoints
}

resource "azurerm_subnet_network_security_group_association" "dp_private" {
  subnet_id                 = azurerm_subnet.dp_private.id
  network_security_group_id = azurerm_network_security_group.dp_sg.id
}

resource "azurerm_subnet" "dp_plsubnet" {
  name                                           = "${local.prefix}-dp-privatelink"
  resource_group_name                            = azurerm_resource_group.dp_rg.name
  virtual_network_name                           = azurerm_virtual_network.dp_vnet.name
  address_prefixes                               = [cidrsubnet(var.cidr_dp, 6, 2)]
  enforce_private_link_endpoint_network_policies = true
}