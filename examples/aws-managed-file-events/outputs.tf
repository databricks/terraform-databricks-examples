output "storage_credential_name" {
  description = "Name of the storage credential"
  value       = module.managed_file_events.storage_credential_name
}

output "external_location_name" {
  description = "Name of the external location"
  value       = module.managed_file_events.external_location_name
}

output "external_location_url" {
  description = "S3 URL of the external location"
  value       = module.managed_file_events.external_location_url
}

output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = module.managed_file_events.bucket_name
}

output "iam_role_arn" {
  description = "ARN of the IAM role"
  value       = module.managed_file_events.iam_role_arn
}
