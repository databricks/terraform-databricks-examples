resource "azurerm_data_factory" "adf" {
  count               = var.data_factory_name != "" ? 1 : 0

  name                = var.data_factory_name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = var.tags
}
