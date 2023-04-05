resource "azurerm_virtual_network" "transit_vnet" {
  name                = "${local.prefix}-transit-vnet"
  location            = azurerm_resource_group.transit_rg.location
  resource_group_name = azurerm_resource_group.transit_rg.name
  address_space       = [var.cidr_transit]
  tags                = local.tags
}

resource "azurerm_network_security_group" "transit_sg" {
  name                = "${local.prefix}-transit-nsg"
  location            = azurerm_resource_group.transit_rg.location
  resource_group_name = azurerm_resource_group.transit_rg.name
  tags                = local.tags
}

resource "azurerm_network_security_rule" "transit_aad" {
  name                        = "AllowAAD-transit"
  priority                    = 200
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "AzureActiveDirectory"
  resource_group_name         = azurerm_resource_group.transit_rg.name
  network_security_group_name = azurerm_network_security_group.transit_sg.name
}

resource "azurerm_network_security_rule" "transit_azfrontdoor" {
  name                        = "AllowAzureFrontDoor-transit"
  priority                    = 201
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "AzureFrontDoor.Frontend"
  resource_group_name         = azurerm_resource_group.transit_rg.name
  network_security_group_name = azurerm_network_security_group.transit_sg.name
}
resource "azurerm_subnet" "transit_public" {
  name                 = "${local.prefix}-transit-public"
  resource_group_name  = azurerm_resource_group.transit_rg.name
  virtual_network_name = azurerm_virtual_network.transit_vnet.name
  address_prefixes     = [cidrsubnet(var.cidr_transit, 6, 0)]

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

resource "azurerm_subnet_network_security_group_association" "transit_public" {
  subnet_id                 = azurerm_subnet.transit_public.id
  network_security_group_id = azurerm_network_security_group.transit_sg.id
}

variable "transit_private_subnet_endpoints" {
  default = []
}

resource "azurerm_subnet" "transit_private" {
  name                 = "${local.prefix}-transit-private"
  resource_group_name  = azurerm_resource_group.transit_rg.name
  virtual_network_name = azurerm_virtual_network.transit_vnet.name
  address_prefixes     = [cidrsubnet(var.cidr_transit, 6, 1)]

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

  service_endpoints = var.transit_private_subnet_endpoints
}

resource "azurerm_subnet_network_security_group_association" "transit_private" {
  subnet_id                 = azurerm_subnet.transit_private.id
  network_security_group_id = azurerm_network_security_group.transit_sg.id
}


resource "azurerm_subnet" "transit_plsubnet" {
  name                                           = "${local.prefix}-transit-privatelink"
  resource_group_name                            = azurerm_resource_group.transit_rg.name
  virtual_network_name                           = azurerm_virtual_network.transit_vnet.name
  address_prefixes                               = [cidrsubnet(var.cidr_transit, 6, 2)]
  enforce_private_link_endpoint_network_policies = true
}