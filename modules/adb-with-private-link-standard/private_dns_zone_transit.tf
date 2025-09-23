resource "azurerm_private_dns_zone" "dns_auth_front" {
  name                = "privatelink.azuredatabricks.net"
  resource_group_name = local.transit_rg_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "transitdnszonevnetlink" {
  name                  = "dpcpspokevnetconnection"
  resource_group_name   = local.transit_rg_name
  private_dns_zone_name = azurerm_private_dns_zone.dns_auth_front.name
  virtual_network_id    = azurerm_virtual_network.transit_vnet.id
}