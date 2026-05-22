output "workspace_url" {
  value       = module.workspace.workspace_url
  description = "The workspace URL which is of the format '{workspaceId}.{random}.gcp.databricks.com'"
}

output "workspace_id" {
  value       = module.workspace.workspace_id
  description = "The Databricks workspace ID"
}

output "vpc_id" {
  value       = module.workspace.vpc_id
  description = "ID of the spoke VPC"
}

output "hub_vpc_id" {
  value       = module.workspace.hub_vpc_id
  description = "ID of the hub VPC"
}

output "network_id" {
  value       = module.workspace.network_id
  description = "databricks_mws_networks ID"
}