data "azurerm_client_config" "current" {}

data "azurerm_databricks_access_connector" "this" {
  name                = local.access_connector_name
  resource_group_name = local.access_connector_rg
}

locals {
  subscription_id = var.subscription_id != "" ? var.subscription_id : data.azurerm_client_config.current.subscription_id

  # Parse /subscriptions/.../resourceGroups/<rg>/providers/Microsoft.Databricks/accessConnectors/<name>
  access_connector_parts = split("/", var.access_connector_id)
  access_connector_name  = element(local.access_connector_parts, length(local.access_connector_parts) - 1)
  access_connector_rg    = element(local.access_connector_parts, index(local.access_connector_parts, "resourceGroups") + 1)

  storage_credential_name = var.storage_credential_name != "" ? var.storage_credential_name : "${var.name_prefix}-storage-credential"

  credential_name = var.create_storage_credential ? databricks_storage_credential.this[0].name : var.existing_credential_name

  # Data-plane role: Reader for read-only locations only when ALL locations are read-only.
  all_read_only           = alltrue([for loc in var.external_locations : loc.read_only])
  blob_data_role_name     = local.all_read_only ? "Storage Blob Data Reader" : "Storage Blob Data Contributor"
  access_connector_principal_id = data.azurerm_databricks_access_connector.this.identity[0].principal_id
}

resource "databricks_storage_credential" "this" {
  count = var.create_storage_credential ? 1 : 0

  name = local.storage_credential_name

  azure_managed_identity {
    access_connector_id = var.access_connector_id
  }

  comment       = "Managed identity credential for external locations with file events. Managed by Terraform."
  force_destroy = var.force_destroy
  force_update  = var.force_destroy
}

resource "databricks_external_location" "this" {
  for_each = { for loc in var.external_locations : loc.name => loc }

  name            = each.value.name
  url             = each.value.url
  credential_name = local.credential_name
  comment         = each.value.comment
  read_only       = each.value.read_only
  force_destroy   = var.force_destroy

  # Automatic managed Azure Queue Storage file events.
  # Requires the Azure RBAC roles assigned in azure_rbac.tf.
  # Docs: https://learn.microsoft.com/en-us/azure/databricks/connect/unity-catalog/cloud-storage/manage-external-locations
  enable_file_events = true
  file_event_queue {
    managed_aqs {
      resource_group  = var.resource_group_name
      subscription_id = local.subscription_id
    }
  }

  depends_on = [
    databricks_storage_credential.this,
    azurerm_role_assignment.blob_data,
    azurerm_role_assignment.queue_data,
    azurerm_role_assignment.storage_account_contributor,
    azurerm_role_assignment.eventgrid_subscription,
  ]
}

resource "databricks_grants" "credential" {
  count = var.create_storage_credential && length(var.credential_grants) > 0 ? 1 : 0

  storage_credential = databricks_storage_credential.this[0].id

  dynamic "grant" {
    for_each = var.credential_grants
    content {
      principal  = grant.value.principal
      privileges = grant.value.privileges
    }
  }
}

resource "databricks_grants" "location" {
  for_each = length(var.location_grants) > 0 ? databricks_external_location.this : {}

  external_location = each.value.id

  dynamic "grant" {
    for_each = var.location_grants
    content {
      principal  = grant.value.principal
      privileges = grant.value.privileges
    }
  }
}
