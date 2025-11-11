# VPC Output
output "vpc_id" {
  description = "ID of the Spoke VPC"
  value       = module.vpc.vpc_id
}

# S3 Bucket Names
output "root_bucket_name" {
  description = "Name of the root storage bucket"
  value       = aws_s3_bucket.root.bucket
}

output "metastore_bucket_name" {
  description = "Name of the Unity Catalog metastore bucket (if created)"
  value       = var.create_metastore_bucket ? aws_s3_bucket.metastore[0].bucket : null
}

output "data_bucket_name" {
  description = "Name of the Unity Catalog data bucket"
  value       = aws_s3_bucket.data.bucket
}

# IAM Roles
output "cross_account_role_arn" {
  description = "ARN of the cross-account IAM role for Databricks"
  value       = aws_iam_role.cross_account.arn
}

output "cross_account_role_name" {
  description = "Name of the cross-account IAM role"
  value       = aws_iam_role.cross_account.name
}

output "unity_catalog_role_arn" {
  description = "ARN of the Unity Catalog IAM role"
  value       = aws_iam_role.unity_catalog.arn
}

output "unity_catalog_role_name" {
  description = "Name of the Unity Catalog IAM role"
  value       = aws_iam_role.unity_catalog.name
}
