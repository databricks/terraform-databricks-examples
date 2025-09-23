//dpcp pvt endpoint
resource "azurerm_private_endpoint" "dpcp" {
  name                = "dpcppvtendpoint"
  location            = local.rg_location
  resource_group_name = local.rg_name
  subnet_id           = azurerm_subnet.plsubnet.id //private link subnet, in databricks spoke vnet

  private_service_connection {
    name                           = "ple-${var.workspace_prefix}-dpcp"
    private_connection_resource_id = azurerm_databricks_workspace.this.id
    is_manual_connection           = false
    subresource_names              = ["databricks_ui_api"]
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-dpcp"
    private_dns_zone_ids = [azurerm_private_dns_zone.dnsdpcp.id]
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_private_dns_zone" "dnsdpcp" {
  name                = "privatelink.azuredatabricks.net"
  resource_group_name = local.rg_name

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "dpcpdnszonevnetlink" {
  name                  = "dpcpspokevnetconnection"
  resource_group_name   = local.rg_name
  private_dns_zone_name = azurerm_private_dns_zone.dnsdpcp.name
  virtual_network_id    = azurerm_virtual_network.this.id // connect to spoke vnet

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_private_endpoint" "auth" {
  name                = "aadauthpvtendpoint"
  location            = local.rg_location
  resource_group_name = local.rg_name
  subnet_id           = azurerm_subnet.plsubnet.id //private link subnet, in databricks spoke vnet

  private_service_connection {
    name                           = "ple-${var.workspace_prefix}-auth"
    private_connection_resource_id = azurerm_databricks_workspace.this.id
    is_manual_connection           = false
    subresource_names              = ["browser_authentication"]
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-auth"
    private_dns_zone_ids = [azurerm_private_dns_zone.dnsdpcp.id]
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

//dbfs pvt endpoint - dfs
resource "azurerm_private_endpoint" "dbfspe_dfs" {
  name                = "dbfspvtendpoint-dfs"
  location            = local.rg_location
  resource_group_name = local.rg_name
  subnet_id           = azurerm_subnet.plsubnet.id //private link subnet, in databricks spoke vnet


  private_service_connection {
    name                           = "ple-${var.workspace_prefix}-dbfs-dfs"
    private_connection_resource_id = join("", [azurerm_databricks_workspace.this.managed_resource_group_id, "/providers/Microsoft.Storage/storageAccounts/${local.dbfsname}"])
    is_manual_connection           = false
    subresource_names              = ["dfs"]
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-dbfs"
    private_dns_zone_ids = [azurerm_private_dns_zone.dnsdbfs_dfs.id]
  }

  lifecycle {
    ignore_changes = [tags]
  }
}
resource "azurerm_private_dns_zone" "dnsdbfs_dfs" {
  name                = "privatelink.dfs.core.windows.net"
  resource_group_name = local.rg_name

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "dbfsdnszonevnetlink_dfs" {
  name                  = "dbfsspokevnetconnection-dfs"
  resource_group_name   = local.rg_name
  private_dns_zone_name = azurerm_private_dns_zone.dnsdbfs_dfs.name
  virtual_network_id    = azurerm_virtual_network.this.id // connect to spoke vnet

  lifecycle {
    ignore_changes = [tags]
  }
}

//dbfs pvt endpoint - blob
resource "azurerm_private_endpoint" "dbfspe_blob" {
  name                = "dbfspvtendpoint-blob"
  location            = local.rg_location
  resource_group_name = local.rg_name
  subnet_id           = azurerm_subnet.plsubnet.id //private link subnet, in databricks spoke vnet


  private_service_connection {
    name                           = "ple-${var.workspace_prefix}-dbfs-blob"
    private_connection_resource_id = join("", [azurerm_databricks_workspace.this.managed_resource_group_id, "/providers/Microsoft.Storage/storageAccounts/${local.dbfsname}"])
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-dbfs"
    private_dns_zone_ids = [azurerm_private_dns_zone.dnsdbfs_blob.id]
  }

  lifecycle {
    ignore_changes = [tags]
  }
}
resource "azurerm_private_dns_zone" "dnsdbfs_blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = local.rg_name

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "dbfsdnszonevnetlink_blob" {
  name                  = "dbfsspokevnetconnection-blob"
  resource_group_name   = local.rg_name
  private_dns_zone_name = azurerm_private_dns_zone.dnsdbfs_blob.name
  virtual_network_id    = azurerm_virtual_network.this.id // connect to spoke vnet

  lifecycle {
    ignore_changes = [tags]
  }
}



# //dpcp pvt endpoint
# resource "azurerm_private_endpoint" "apim" {
