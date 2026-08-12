output "workspace_id" {
  value       = module.workspace.workspace_id
  description = "Databricks workspace ID"
}

output "workspace_url" {
  value       = module.workspace.workspace_url
  description = "Databricks workspace URL"
}

output "vpc_id" {
  value       = module.workspace.spoke_vpc_id
  description = "ID of the spoke VPC created by the module"
}

output "network_id" {
  value       = module.workspace.network_id
  description = "databricks_mws_networks ID"
}