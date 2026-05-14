output "workspace_id" {
  value       = module.account.workspace_id
  description = "Databricks workspace ID"
}

output "workspace_url" {
  value       = module.account.workspace_url
  description = "Databricks workspace URL"
}

output "network_id" {
  value       = module.account.network_id
  description = "mws_networks ID (null when databricks_managed)"
}

output "vpc_id" {
  value       = try(module.network[0].spoke_vpc_id, null)
  description = "Spoke VPC ID (null when databricks_managed)"
}

output "spoke_vpc_id" {
  value       = try(module.network[0].spoke_vpc_id, null)
  description = "Spoke VPC ID (null when databricks_managed)"
}

output "hub_vpc_id" {
  value       = try(module.network[0].hub_vpc_id, null)
  description = "Hub VPC ID (null when not restricted_egress)"
}

output "suffix" {
  value       = random_string.suffix.result
  description = "Random suffix used in resource names"
}
