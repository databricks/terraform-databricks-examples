resource "azurerm_virtual_network" "this" {
  name                = "project-${local.prefix}-vnet"
  resource_group_name = azurerm_resource_group.this.name
  location            = local.location
  address_space       = [var.cidr]
  tags                = local.tags
}

resource "azurerm_network_security_group" "vmnsg" {
  name                = "${local.prefix}-vm-nsg"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  security_rule {
    name                       = "allow_ssh"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.teradatasubnet.id
  network_security_group_id = azurerm_network_security_group.vmnsg.id
}

resource "azurerm_subnet" "teradatasubnet" {
  name                 = "adb-teradata-${local.prefix}-vm-subnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [cidrsubnet(var.cidr, 3, 0)]
}

// For Databricks workspace
resource "azurerm_subnet" "adb-public-subnet" {
  name                 = "adb-${local.prefix}-public-subnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [cidrsubnet(var.cidr, 3, 1)]
}

resource "azurerm_subnet" "adb-private-subnet" {
  name                 = "adb-${local.prefix}-private-subnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [cidrsubnet(var.cidr, 3, 2)]
}
