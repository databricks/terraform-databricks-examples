// For DFS
resource "azurerm_private_endpoint" "dp_dbfspe_dfs" {
  name                = "dbfspvtendpoint-dp-dfs"
  location            = azurerm_resource_group.dp_rg.location
  resource_group_name = azurerm_resource_group.dp_rg.name
  subnet_id           = azurerm_subnet.dp_plsubnet.id


  private_service_connection {
    name                           = "ple-${local.prefix}-dp-dbfs-dfs"
    private_connection_resource_id = join("", [azurerm_databricks_workspace.dp_workspace.managed_resource_group_id, "/providers/Microsoft.Storage/storageAccounts/${local.dbfsname}"])
    is_manual_connection           = false
    subresource_names              = ["dfs"]
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-dbfs-dfs"
    private_dns_zone_ids = [azurerm_private_dns_zone.dnsdbfs_dfs.id]
  }
}

// for Blob
resource "azurerm_private_endpoint" "dp_dbfspe_blob" {
  name                = "dbfspvtendpoint-dp-blob"
  location            = azurerm_resource_group.dp_rg.location
  resource_group_name = azurerm_resource_group.dp_rg.name
  subnet_id           = azurerm_subnet.dp_plsubnet.id


  private_service_connection {
    name                           = "ple-${local.prefix}-dp-dbfs-blob"
    private_connection_resource_id = join("", [azurerm_databricks_workspace.dp_workspace.managed_resource_group_id, "/providers/Microsoft.Storage/storageAccounts/${local.dbfsname}"])
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-dbfs-blob"
    private_dns_zone_ids = [azurerm_private_dns_zone.dnsdbfs_blob.id]
  }
}
