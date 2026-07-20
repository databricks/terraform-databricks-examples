output "iam_role_name" {
  description = "Name of the IAM role backing the storage credential"
  value       = aws_iam_role.this.name
}

output "iam_role_arn" {
  description = "ARN of the IAM role trusted by the Unity Catalog storage credential"
  value       = aws_iam_role.this.arn
}

output "iam_policy_arn" {
  description = "ARN of the IAM policy attached to the role"
  value       = aws_iam_policy.this.arn
}

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

output "file_events_enabled" {
  description = "Whether managed file events are enabled on the external locations"
  value       = var.enable_file_events
}
