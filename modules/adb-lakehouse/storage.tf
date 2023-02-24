resource "azurerm_storage_account" "dls" {
  count                    = length(var.storage_account_names)
  name                     = "dls${var.storage_account_names[count.index]}${var.environment_name}"
  location                 = var.location
  resource_group_name      = var.databricks_resource_group_name
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags                     = var.tags
  is_hns_enabled           = true
}

resource "azurerm_storage_container" "checkpoint-container" {
  name                  = "checkpoint"
  storage_account_name  = azurerm_storage_account.dls[1].name
  container_access_type = "private"
}
