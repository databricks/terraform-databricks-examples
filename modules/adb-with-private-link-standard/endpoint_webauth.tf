resource "azurerm_private_endpoint" "transit_auth" {
  name                = "aadauthpvtendpoint-transit"
  location            = azurerm_resource_group.transit_rg.location
  resource_group_name = azurerm_resource_group.transit_rg.name
  subnet_id           = azurerm_subnet.transit_plsubnet.id

  private_service_connection {
    name                           = "ple-${local.prefix}-auth"
    private_connection_resource_id = azurerm_databricks_workspace.transit_workspace.id
    is_manual_connection           = false
    subresource_names              = ["browser_authentication"]
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-auth"
    private_dns_zone_ids = [azurerm_private_dns_zone.dnsdpcp.id]
  }
}

resource "azurerm_databricks_workspace" "transit_workspace" {
  name                                  = "${local.prefix}-transit-workspace"
  resource_group_name                   = azurerm_resource_group.transit_rg.name
  location                              = azurerm_resource_group.transit_rg.location
  sku                                   = "premium"
  tags                                  = local.tags
  public_network_access_enabled         = false                    //use private endpoint
  network_security_group_rules_required = "NoAzureDatabricksRules" //use private endpoint
  customer_managed_key_enabled          = true
  //infrastructure_encryption_enabled = true
  custom_parameters {
    no_public_ip                                         = true
    virtual_network_id                                   = azurerm_virtual_network.transit_vnet.id
    private_subnet_name                                  = azurerm_subnet.transit_private.name
    public_subnet_name                                   = azurerm_subnet.transit_public.name
    public_subnet_network_security_group_association_id  = azurerm_subnet_network_security_group_association.transit_public.id
    private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.transit_private.id
    storage_account_name                                 = "${local.dbfsname}auth"
  }
  # We need this, otherwise destroy doesn't cleanup things correctly
  depends_on = [
    azurerm_subnet_network_security_group_association.transit_public,
    azurerm_subnet_network_security_group_association.transit_private
  ]
}