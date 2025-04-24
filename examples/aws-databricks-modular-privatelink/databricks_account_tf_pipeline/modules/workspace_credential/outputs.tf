output "storage_credential_id" {
  value = databricks_mws_credentials.this.credentials_id
}

output "cross_account_role_arn" {
  value = aws_iam_role.cross_account_role.arn
}

