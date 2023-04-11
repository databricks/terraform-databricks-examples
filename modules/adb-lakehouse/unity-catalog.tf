resource "azurerm_resource_group" "shared_resource_group" {
  name     = var.shared_resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_databricks_access_connector" "access_connector" {
  name                = var.access_connector_name
  resource_group_name = azurerm_resource_group.shared_resource_group.name
  location            = azurerm_resource_group.shared_resource_group.location
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_storage_account" "unity_catalog" {
  name                     = var.metastore_storage_name
  location                 = azurerm_resource_group.shared_resource_group.location
  resource_group_name      = var.shared_resource_group_name
  tags                     = var.tags
  account_tier             = "Standard"
  account_replication_type = "GRS"
  is_hns_enabled           = true
}

resource "azurerm_storage_container" "unity_catalog" {
  name                  = "${var.metastore_storage_name}-container"
  storage_account_name  = azurerm_storage_account.unity_catalog.name
  container_access_type = "private"
}

resource "azurerm_role_assignment" "example" {
  scope                = azurerm_storage_account.unity_catalog.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_databricks_access_connector.access_connector.identity[0].principal_id
}
