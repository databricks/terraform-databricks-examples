
resource "azurerm_databricks_workspace" "dp_workspace" {
  name                                  = "${local.prefix}-dp-workspace"
  resource_group_name                   = local.dp_rg_name
  location                              = local.dp_rg_location
  sku                                   = "premium"
  tags                                  = local.tags
  public_network_access_enabled         = var.public_network_access_enabled
  network_security_group_rules_required = "NoAzureDatabricksRules"
  customer_managed_key_enabled          = true
  custom_parameters {
    virtual_network_id                                   = azurerm_virtual_network.dp_vnet.id
    private_subnet_name                                  = azurerm_subnet.dp_private.name
    public_subnet_name                                   = azurerm_subnet.dp_public.name
    public_subnet_network_security_group_association_id  = azurerm_subnet_network_security_group_association.dp_public.id
    private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.dp_private.id
    storage_account_name                                 = local.dbfsname
  }
  depends_on = [
    azurerm_subnet_network_security_group_association.dp_public,
    azurerm_subnet_network_security_group_association.dp_private
  ]
}

