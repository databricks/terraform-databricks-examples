output "databricks_hosts" {
  value = tomap({
    for k, ws in module.workspace_collection : k => ws.workspace_url
  })
}

output "cross_account_role_arn" {
  value = module.aws_iam.cross_account_role_arn
}

output "role_for_s3_access_id" {
  value = module.aws_data.role_for_s3_access_id
}

output "role_for_s3_access_name" {
  value = module.aws_data.role_for_s3_access_name
}

output "instance_profile_arn" {
  value = module.aws_data.instance_profile_arn
}

output "vpc_id" {
  value = module.aws_network.vpc_id
}

output "databricks_security_group_id" {
  value = module.aws_security.databricks_security_group_id
}

output "privatelink_security_group_id" {
  value = module.aws_security.privatelink_security_group_id
}