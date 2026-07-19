output "storage_credential_name" {
  description = "Name of the storage credential used by the external locations"
  value       = local.credential_name
}

output "storage_credential_id" {
  description = "ID of the created storage credential (null when reusing an existing credential)"
  value       = try(databricks_storage_credential.this[0].id, null)
}

output "external_location_names" {
  description = "Names of the created external locations"
  value       = [for loc in databricks_external_location.this : loc.name]
}

output "external_location_ids" {
  description = "Map of external location name to ID"
  value       = { for k, v in databricks_external_location.this : k => v.id }
}

output "external_location_urls" {
  description = "Map of external location name to URL"
  value       = { for k, v in databricks_external_location.this : k => v.url }
}

output "azure_rbac_roles" {
  description = "Azure RBAC roles assigned to the access connector managed identity when assign_azure_rbac is true"
  value = var.assign_azure_rbac ? {
    storage_account = [
      local.blob_data_role_name,
      "Storage Queue Data Contributor",
      "Storage Account Contributor",
    ]
    resource_group = [
      "EventGrid EventSubscription Contributor",
    ]
  } : null
}
