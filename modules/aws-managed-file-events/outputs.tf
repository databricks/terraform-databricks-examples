output "bucket_name" {
  description = "Name of the S3 bucket used for file events"
  value       = local.bucket_name
}

output "bucket_arn" {
  description = "ARN of the S3 bucket used for file events"
  value       = var.create_bucket ? aws_s3_bucket.file_events[0].arn : data.aws_s3_bucket.existing[0].arn
}

output "s3_url" {
  description = "S3 URL for the external location"
  value       = local.s3_url
}

output "iam_role_arn" {
  description = "ARN of the IAM role for file events access"
  value       = aws_iam_role.file_events_access.arn
}

output "iam_role_name" {
  description = "Name of the IAM role for file events access"
  value       = aws_iam_role.file_events_access.name
}

output "storage_credential_id" {
  description = "ID of the storage credential"
  value       = databricks_storage_credential.file_events.id
}

output "storage_credential_name" {
  description = "Name of the storage credential"
  value       = databricks_storage_credential.file_events.name
}

output "external_location_id" {
  description = "ID of the external location"
  value       = databricks_external_location.file_events.id
}

output "external_location_name" {
  description = "Name of the external location"
  value       = databricks_external_location.file_events.name
}

output "external_location_url" {
  description = "URL of the external location"
  value       = databricks_external_location.file_events.url
}


output "catalog_id" {
  description = "ID of the catalog (if created)"
  value       = var.create_catalog ? databricks_catalog.file_events[0].id : null
}

output "catalog_name" {
  description = "Name of the catalog (if created)"
  value       = var.create_catalog ? databricks_catalog.file_events[0].name : null
}
