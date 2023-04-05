resource "azurerm_storage_account" "allowedstorage" {
  name                = "${random_string.naming.result}allowedstorage"
  resource_group_name = azurerm_resource_group.this.name

  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
  tags                     = local.tags
}


resource "azurerm_storage_account" "deniedstorage" {
  name                = "${random_string.naming.result}deniedstorage"
  resource_group_name = azurerm_resource_group.this.name

  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
  tags                     = local.tags
}
