output "databricks_hosts" {
  value = tomap({
    for k, ws in module.workspace_collection : k => ws.workspace_url
  })
}

output "arn" {
  value = aws_iam_role.cross_account_role.arn
}

/*
// export token for integration tests to run on
output "databricks_token" {
  value     = databricks_token.pat.token_value
  sensitive = true
}
*/
