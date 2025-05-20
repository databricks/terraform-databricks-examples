output "cross_account_role_arn" {
  value = [for i in module.workspace_credential : i.cross_account_role_arn]
}

output "workspace_security_group_ids" {
  value = module.aws_network.workspace_security_group_ids
}

output "privatelink_security_group_ids" {
  value = module.aws_network.privatelink_security_group_ids
}

output "databricks_host" {
  value = databricks_mws_workspaces.workspaces_collection[*].workspace_url
}

output "workspace_ids" {
  value = databricks_mws_workspaces.workspaces_collection[*].workspace_id
}

output "metastore_id" {
  value = var.deploy_metastore == "true" ? databricks_metastore.this[0].metastore_id : null
}
