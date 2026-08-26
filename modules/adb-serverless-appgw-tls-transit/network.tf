locals {
  tags = merge(
    {
      ManagedBy = "terraform"
      Module    = "adb-serverless-appgw-tls-transit"
    },
    var.tags,
  )
}

resource "azurerm_resource_group" "this" {
  name     = var.rg_name
  location = var.azure_region
  tags     = local.tags
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-${var.appgw_name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = var.vnet_address_space
  tags                = local.tags
}

resource "azurerm_subnet" "appgw" {
  name                 = "snet-appgw"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.appgw_subnet_prefix]
}

resource "azurerm_subnet" "appgw_pls" {
  name                 = "snet-appgw-pls"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.appgw_pls_subnet_prefix]

  # Required for the Application Gateway Private Link configuration.
  private_link_service_network_policies_enabled = false
}

# Keep the public-facing management surface from accepting Internet traffic.
# GatewayManager and AzureLoadBalancer need the documented health/management
# ports for the Application Gateway service to operate.
resource "azurerm_network_security_group" "appgw" {
  name                = "nsg-${var.appgw_name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags

  security_rule {
    name                       = "allow-gateway-manager"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "65200-65535"
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-azure-load-balancer"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "65503-65534"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "deny-internet"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "appgw" {
  subnet_id                 = azurerm_subnet.appgw.id
  network_security_group_id = azurerm_network_security_group.appgw.id
}
