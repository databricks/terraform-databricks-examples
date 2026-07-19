# Documented Azure RBAC for automatic managed file events on ADLS Gen2.
# See: https://learn.microsoft.com/en-us/azure/databricks/connect/unity-catalog/cloud-storage/manage-external-locations
#
# Storage account:
#   - Storage Blob Data Contributor|Reader  — data plane access
#   - Storage Queue Data Contributor        — subscribe to file-change notifications
#   - Storage Account Contributor           — let Databricks auto-create the queue / routing
# Resource group:
#   - EventGrid EventSubscription Contributor — let Databricks auto-create Event Grid subscriptions

resource "azurerm_role_assignment" "blob_data" {
  count = var.assign_azure_rbac ? 1 : 0

  scope                = var.storage_account_id
  role_definition_name = local.blob_data_role_name
  principal_id         = local.access_connector_principal_id
}

resource "azurerm_role_assignment" "queue_data" {
  count = var.assign_azure_rbac ? 1 : 0

  scope                = var.storage_account_id
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = local.access_connector_principal_id
}

resource "azurerm_role_assignment" "storage_account_contributor" {
  count = var.assign_azure_rbac ? 1 : 0

  scope                = var.storage_account_id
  role_definition_name = "Storage Account Contributor"
  principal_id         = local.access_connector_principal_id
}

resource "azurerm_role_assignment" "eventgrid_subscription" {
  count = var.assign_azure_rbac ? 1 : 0

  scope                = "/subscriptions/${local.subscription_id}/resourceGroups/${var.resource_group_name}"
  role_definition_name = "EventGrid EventSubscription Contributor"
  principal_id         = local.access_connector_principal_id
}
