output "databricks_security_group_id" {
  value = aws_security_group.databricks.id
}

output "privatelink_security_group_id" {
  value = aws_security_group.privatelink.id
}

output "workspace_storage_cmk" {
  value = {
    key_alias = aws_kms_alias.workspace_storage_cmk_alias.name
    key_arn   = aws_kms_key.workspace_storage_cmk.arn
  }
}

output "managed_services_cmk" {
  value = {
    key_alias = aws_kms_alias.managed_services_cmk_alias.name
    key_arn   = aws_kms_key.managed_services_cmk.arn
  }
}