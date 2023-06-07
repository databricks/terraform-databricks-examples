resource "azurerm_storage_account" "sqlserversa" {
  name                     = "${random_string.naming.result}sqlserversa"
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_mssql_server" "metastoreserver" {
  name                          = "${random_string.naming.result}mssqlserver"
  resource_group_name           = azurerm_resource_group.this.name
  location                      = azurerm_resource_group.this.location
  version                       = "12.0"
  administrator_login           = var.db_username // sensitive data stored as env variables locally
  administrator_login_password  = var.db_password
  public_network_access_enabled = true // consider to disable public access to the server, to set as false
}

resource "azurerm_mssql_database" "sqlmetastore" {
  name           = "${random_string.naming.result}metastore"
  server_id      = azurerm_mssql_server.metastoreserver.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  read_scale     = true
  max_size_gb    = 4
  sku_name       = "BC_Gen5_2"
  zone_redundant = true
  tags           = local.tags

}

resource "azurerm_mssql_server_extended_auditing_policy" "mssqlpolicy" {
  server_id                               = azurerm_mssql_server.metastoreserver.id
  storage_endpoint                        = azurerm_storage_account.sqlserversa.primary_blob_endpoint
  storage_account_access_key              = azurerm_storage_account.sqlserversa.primary_access_key
  storage_account_access_key_is_secondary = false
  retention_in_days                       = 6
}

resource "azurerm_mssql_virtual_network_rule" "sqlservervnetrule" {
  // associate sql server to a subnet
  name      = "sql-server-vnet-rule"
  server_id = azurerm_mssql_server.metastoreserver.id
  subnet_id = azurerm_subnet.sqlsubnet.id
}

// add private endpoint connection to sql server / metastore
resource "azurerm_private_endpoint" "sqlserverpe" {
  name                = "sqlserverpvtendpoint"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = azurerm_subnet.plsubnet.id //private link subnet, in databricks vnet

  private_service_connection {
    name                           = "ple-${var.workspace_prefix}-metastore"
    private_connection_resource_id = azurerm_mssql_server.metastoreserver.id
    is_manual_connection           = false
    subresource_names              = ["sqlServer"]
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-metastore"
    private_dns_zone_ids = [azurerm_private_dns_zone.dnsmetastore.id]
  }
}

resource "azurerm_private_dns_zone" "dnsmetastore" {
  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "metastorednszonevnetlink" {
  name                  = "metastorednsvnetconnection"
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.dnsmetastore.name
  virtual_network_id    = azurerm_virtual_network.this.id // connect to databricks vnet
}
