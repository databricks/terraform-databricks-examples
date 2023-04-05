resource "azurerm_resource_group" "this" {
  name     = var.shared_resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azapi_resource" "access_connector" {
  type      = "Microsoft.Databricks/accessConnectors@2022-04-01-preview"
  name      = var.access_connector_name
  location  = azurerm_resource_group.this.location
  parent_id = azurerm_resource_group.this.id
  identity {
    type = "SystemAssigned"
  }
  body = jsonencode({
    properties = {}
  })
}

resource "azurerm_storage_account" "unity_catalog" {
  name                     = var.metastore_storage_name
  location                 = azurerm_resource_group.this.location
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
  principal_id         = azapi_resource.access_connector.identity[0].principal_id
}
