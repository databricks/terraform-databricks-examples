output "cross_account_role_arn" {
  value = aws_iam_role.cross_account_role.arn
}

output "credentials_id" {
  value = databricks_mws_credentials.this.credentials_id
}

output "cross_account_policy" {
  value = data.databricks_aws_crossaccount_policy.this.json
}