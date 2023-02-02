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

output "role_for_s3_access_id" {
  value = aws_iam_role.role_for_s3_access.id
}

output "role_for_s3_access_name" {
  value = aws_iam_role.role_for_s3_access.name
}

output "instance_profile_arn" {
  value = aws_iam_instance_profile.instance_profile.arn
}
/*
output "databricks_instance_profile_id" {
  value = databricks_instance_profile.instance_profile.id
}
*/
