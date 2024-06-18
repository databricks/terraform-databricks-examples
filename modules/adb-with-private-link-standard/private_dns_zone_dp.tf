resource "azurerm_private_dns_zone" "dnsdpcp" {
  name                = "privatelink.azuredatabricks.net"
  resource_group_name = azurerm_resource_group.dp_rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dpcpdnszonevnetlink" {
  name                  = "dpcpspokevnetconnection"
  resource_group_name   = azurerm_resource_group.dp_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dnsdpcp.name
  virtual_network_id    = azurerm_virtual_network.dp_vnet.id
}

resource "azurerm_private_dns_zone" "dnsdbfs_dfs" {
  name                = "privatelink.dfs.core.windows.net"
  resource_group_name = azurerm_resource_group.dp_rg.name
}

resource "azurerm_private_dns_zone" "dnsdbfs_blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.dp_rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dbfsdnszonevnetlink_dfs" {
  name                  = "dbfsspokevnetconnection-dfs"
  resource_group_name   = azurerm_resource_group.dp_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dnsdbfs_dfs.name
  virtual_network_id    = azurerm_virtual_network.dp_vnet.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "dbfsdnszonevnetlink_blob" {
  name                  = "dbfsspokevnetconnection-blob"
  resource_group_name   = azurerm_resource_group.dp_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dnsdbfs_blob.name
  virtual_network_id    = azurerm_virtual_network.dp_vnet.id
}



