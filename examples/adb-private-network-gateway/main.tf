resource "azurerm_resource_group" "this" {
  name     = "rg-${var.prefix}"
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-${var.prefix}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = [var.vnet_address_space]
  tags                = var.tags
}

// Static public IP and NAT gateway. When attached to the gateway subnet,
// internet-bound traffic that enters the gateway (ALL_TRAFFIC mode) leaves
// from this IP.
resource "azurerm_public_ip" "nat" {
  name                = "pip-${var.prefix}-nat"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_nat_gateway" "this" {
  name                = "nat-${var.prefix}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku_name            = "Standard"
  tags                = var.tags
}

resource "azurerm_nat_gateway_public_ip_association" "this" {
  nat_gateway_id       = azurerm_nat_gateway.this.id
  public_ip_address_id = azurerm_public_ip.nat.id
}

// Link existing private DNS zones to the VNet so the gateway resolves the
// private names in them with Azure-provided DNS.
resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each = toset(var.private_dns_zone_ids)

  name                  = "${var.prefix}-${element(split("/", each.value), 8)}"
  resource_group_name   = element(split("/", each.value), 4)
  private_dns_zone_name = element(split("/", each.value), 8)
  virtual_network_id    = azurerm_virtual_network.this.id
  tags                  = var.tags
}

resource "databricks_mws_network_connectivity_config" "this" {
  name   = "${var.prefix}-ncc"
  region = var.location
}

module "private_network_gateway" {
  source = "../../modules/adb-private-network-gateway"

  databricks_account_id          = var.databricks_account_id
  network_connectivity_config_id = databricks_mws_network_connectivity_config.this.network_connectivity_config_id
  location                       = var.location
  resource_group_name            = azurerm_resource_group.this.name
  virtual_network_name           = azurerm_virtual_network.this.name
  gateway_subnet_name            = "snet-${var.prefix}-png"
  gateway_subnet_address_prefix  = var.gateway_subnet_address_prefix
  display_name                   = "${var.prefix}-png"
  traffic_mode                   = var.traffic_mode
  destinations                   = var.destinations
  private_dns_resolvers          = var.private_dns_resolvers
  bandwidth_tier_gbps            = var.bandwidth_tier_gbps
  attach_nat_gateway             = var.attach_nat_gateway
  nat_gateway_id                 = azurerm_nat_gateway.this.id

  depends_on = [
    azurerm_nat_gateway_public_ip_association.this,
    azurerm_private_dns_zone_virtual_network_link.this,
  ]
}

// Optional: attach the NCC to an existing workspace in the same region.
// Serverless compute in that workspace then uses the gateway.
resource "databricks_mws_ncc_binding" "this" {
  count = var.workspace_id == null ? 0 : 1

  network_connectivity_config_id = databricks_mws_network_connectivity_config.this.network_connectivity_config_id
  workspace_id                   = var.workspace_id

  depends_on = [module.private_network_gateway]
}
