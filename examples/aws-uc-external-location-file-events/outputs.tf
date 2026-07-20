output "bucket_name" {
  value = aws_s3_bucket.this.id
}

output "iam_role_arn" {
  value = module.uc_external_location_file_events.iam_role_arn
}

output "storage_credential_name" {
  value = module.uc_external_location_file_events.storage_credential_name
}

output "external_location_ids" {
  value = module.uc_external_location_file_events.external_location_ids
}

output "external_location_urls" {
  value = module.uc_external_location_file_events.external_location_urls
}
