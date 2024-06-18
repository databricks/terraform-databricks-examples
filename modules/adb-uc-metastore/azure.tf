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

locals {
  # Steps 2-4 in https://learn.microsoft.com/en-us/azure/databricks/data-governance/unity-catalog/azure-managed-identities#--step-2-grant-the-managed-identity-access-to-the-storage-account
  uc_roles = [
    "Storage Blob Data Contributor",  # Normal data access
    "Storage Queue Data Contributor", # File arrival triggers
    "EventGrid EventSubscription Contributor",
  ]
}

resource "azurerm_role_assignment" "unity_catalog" {
  for_each             = toset(local.uc_roles)
  scope                = azurerm_storage_account.unity_catalog.id
  role_definition_name = each.value
  principal_id         = azurerm_databricks_access_connector.access_connector.identity[0].principal_id
}
