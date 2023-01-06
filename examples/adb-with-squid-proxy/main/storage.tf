resource "random_id" "storage_account" {
  byte_length = 8
}

resource "azurerm_storage_account" "testsa" {
  name                     = lower(random_id.storage_account.hex)
  resource_group_name      = azurerm_resource_group.this.name
  is_hns_enabled           = true
  location                 = "southeastasia"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = local.tags
}
