resource "azurerm_storage_account" "storage" {
  name                     = var.storagename
  resource_group_name      = var.resource_group_name
  location                 = var.locationtest
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
}
