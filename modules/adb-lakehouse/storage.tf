resource "azurerm_storage_account" "dls" {
  count                    = length(var.storage_account_names)
  name                     = "dls${var.storage_account_names[count.index]}${var.environment_name}"
  location                 = local.rg_location
  resource_group_name      = local.rg_name
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags                     = var.tags
  is_hns_enabled           = true
}
