output "uc_bucket_name" {
  value = aws_s3_bucket.uc_demo.bucket
}

output "uc_iam_role_arn" {
  value = aws_iam_role.uc_demo.arn
}

output "uc_storage_credential_name" {
  value = databricks_storage_credential.uc_demo.name
}

output "uc_external_location_name" {
  value = databricks_external_location.uc_demo.name
}

output "uc_catalog_name" {
  value = databricks_catalog.uc_demo.name
}
