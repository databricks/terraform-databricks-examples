resource "azurerm_virtual_network" "dbvnet" {
  name                = "${local.prefix}-vnet"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = [local.dbcidr]
  tags                = local.tags
}

resource "azurerm_network_security_group" "dbnsg" {
  name                = "${local.prefix}-nsg"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags
}

resource "azurerm_subnet" "public" {
  name                 = "${local.prefix}-public"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.dbvnet.name
  address_prefixes     = [cidrsubnet(local.dbcidr, 3, 0)]

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

resource "azurerm_subnet_network_security_group_association" "public" {
  subnet_id                 = azurerm_subnet.public.id
  network_security_group_id = azurerm_network_security_group.dbnsg.id
}

resource "azurerm_subnet" "private" {
  name                 = "${local.prefix}-private"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.dbvnet.name
  address_prefixes     = [cidrsubnet(local.dbcidr, 3, 1)]

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

resource "azurerm_subnet_network_security_group_association" "private" {
  subnet_id                 = azurerm_subnet.private.id
  network_security_group_id = azurerm_network_security_group.dbnsg.id
}


resource "azurerm_virtual_network" "squidvnet" {
  name                = "${local.prefix}-squid-vnet"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = [local.squidcidr]
  tags                = local.tags
}

resource "azurerm_subnet" "squid-public-subnet" {
  name                 = "${local.prefix}-squid-public"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.squidvnet.name
  address_prefixes     = [cidrsubnet(local.squidcidr, 3, 0)]
}


# peering
resource "azurerm_virtual_network_peering" "squid2db" {
  name                      = "squid2db"
  resource_group_name       = azurerm_resource_group.this.name
  virtual_network_name      = azurerm_virtual_network.squidvnet.name
  remote_virtual_network_id = azurerm_virtual_network.dbvnet.id
}

resource "azurerm_virtual_network_peering" "db2squid" {
  name                      = "db2squid"
  resource_group_name       = azurerm_resource_group.this.name
  virtual_network_name      = azurerm_virtual_network.dbvnet.name
  remote_virtual_network_id = azurerm_virtual_network.squidvnet.id
}

resource "azurerm_network_security_group" "squidnsg" {
  name                = "${local.prefix}-nsg"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags
}

resource "azurerm_network_security_rule" "ssh" {
  name                        = "ssh_squid"
  priority                    = 300
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*" //temporary rule for testing, allow any ip to connect; you can change to your client ip
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.squidnsg.name
}

resource "azurerm_network_security_rule" "http_squid" {
  name                        = "http_squid"
  priority                    = 301
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3128"
  source_address_prefix       = azurerm_virtual_network.dbvnet.address_space.0 //from db clusters
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.squidnsg.name
}

resource "azurerm_network_security_rule" "https_squid" {
  name                        = "https_squid"
  priority                    = 302
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3130"
  source_address_prefix       = azurerm_virtual_network.dbvnet.address_space.0 //from db clusters
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.squidnsg.name
}


resource "azurerm_network_security_rule" "http_out_squid" {
  name                        = "http_out_squid"
  priority                    = 303
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "0.0.0.0/0"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.squidnsg.name
}

resource "azurerm_network_security_rule" "https_out_squid" {
  name                        = "https_out_squid"
  priority                    = 304
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "0.0.0.0/0"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.squidnsg.name
}

resource "azurerm_network_interface_security_group_association" "nsg_nic_assoc" {
  network_interface_id      = azurerm_network_interface.squid-nic.id
  network_security_group_id = azurerm_network_security_group.squidnsg.id
}
