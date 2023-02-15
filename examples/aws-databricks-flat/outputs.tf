// export host to be used by other modules
output "databricks_host" {
  value = databricks_mws_workspaces.this.workspace_url
}

// export token for integration tests to run on
output "databricks_token" {
  value     = databricks_token.pat.token_value
  sensitive = true
}

output "arn" {
  value = aws_iam_role.cross_account_role.arn
}
