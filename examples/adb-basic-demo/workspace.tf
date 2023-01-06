resource "azurerm_databricks_workspace" "example" {
  name                = "${local.prefix}-workspace"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "premium"
  tags                = local.tags
  custom_parameters {
    no_public_ip             = var.no_public_ip
    storage_account_name     = local.dbfsname
    storage_account_sku_name = "Standard_LRS"
  }
}
