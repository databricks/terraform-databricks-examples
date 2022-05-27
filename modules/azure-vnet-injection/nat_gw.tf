resource "azurerm_public_ip" "this" {
  name                = "${var.prefix}-nat-gw-public-ip"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1"]
}

resource "azurerm_public_ip_prefix" "this" {
  name                = "${var.prefix}-nat-gw-public-ip-prefix"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  prefix_length       = 30
  zones               = ["1"]
}

resource "azurerm_nat_gateway" "this" {
  name                                                = "${var.prefix}-nat-gw"
  location                                            = azurerm_resource_group.this.location
  resource_group_name                                 = azurerm_resource_group.this.name
  #azurerm_nat_gateway_public_ip_association           = [azurerm_public_ip.this.id]
  #azurerm_nat_gateway_public_ip_prefix_association    = [azurerm_public_ip_prefix.this.id]
  sku_name                                            = "Standard"
  idle_timeout_in_minutes                             = 10
  zones                                               = ["1"]
}

resource "azurerm_nat_gateway_public_ip_association" "this" {
  nat_gateway_id       = azurerm_nat_gateway.this.id
  public_ip_address_id = azurerm_public_ip.this.id
}

resource "azurerm_nat_gateway_public_ip_prefix_association" "this" {
  nat_gateway_id      = azurerm_nat_gateway.this.id
  public_ip_prefix_id = azurerm_public_ip_prefix.this.id
}

resource "azurerm_subnet_nat_gateway_association" "example" {
  subnet_id      = azurerm_subnet.public.id
  nat_gateway_id = azurerm_nat_gateway.this.id
}