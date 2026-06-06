locals {
  # The frontend that carries the Private Link configuration. This name is also
  # the NCC private-endpoint-rule group_id (see ncc.tf) — they must match.
  frontend_pl_name = "frontend-public"
  pl_config_name   = "pl-config"
  listener_name    = "listener-tcp"
  backend_port     = coalesce(var.backend_port, var.listener_port)

  default_tags = {
    ManagedBy = "terraform"
    Module    = "adb-serverless-appgw-tls-transit"
  }
  tags = merge(local.default_tags, var.tags)
}

resource "azurerm_resource_group" "this" {
  name     = var.rg_name
  location = var.azure_region
  tags     = local.tags
}

resource "azurerm_virtual_network" "transit" {
  name                = "vnet-${var.appgw_name}"
  location            = var.azure_region
  resource_group_name = azurerm_resource_group.this.name
  address_space       = var.vnet_address_space
  tags                = local.tags
}

# Dedicated subnet for the Application Gateway.
resource "azurerm_subnet" "appgw" {
  name                 = "snet-appgw"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.transit.name
  address_prefixes     = [var.appgw_subnet_prefix]
}

# Subnet hosting the App Gateway Private Link configuration IP. PL network
# policies must be disabled here.
resource "azurerm_subnet" "appgw_pls" {
  name                 = "snet-appgw-pls"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.transit.name
  address_prefixes     = [var.appgw_pls_subnet_prefix]

  private_link_service_network_policies_enabled = false
}
