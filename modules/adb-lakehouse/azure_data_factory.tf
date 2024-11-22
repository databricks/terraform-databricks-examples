resource "azurerm_data_factory" "adf" {
  count = var.data_factory_name != "" ? 1 : 0

  name                = var.data_factory_name
  location            = local.rg_location
  resource_group_name = local.rg_name
  tags                = var.tags
}
