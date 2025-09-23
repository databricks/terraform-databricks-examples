resource "azurerm_private_endpoint" "dp_dpcp" {
  name                = "dpcppvtendpoint-dp"
  location            = local.dp_rg_location
  resource_group_name = local.dp_rg_name
  subnet_id           = azurerm_subnet.dp_plsubnet.id

  private_service_connection {
    name                           = "ple-${local.prefix}-dp-dpcp"
    private_connection_resource_id = azurerm_databricks_workspace.dp_workspace.id
    is_manual_connection           = false
    subresource_names              = ["databricks_ui_api"]
  }

  private_dns_zone_group {
    name                 = "dp-private-dns-zone-dpcp"
    private_dns_zone_ids = [azurerm_private_dns_zone.dnsdpcp.id]
  }
}