output "workspace_id" {
  value       = databricks_mws_workspaces.this.workspace_id
  description = "Databricks workspace ID"
}

output "workspace_url" {
  value       = databricks_mws_workspaces.this.workspace_url
  description = "Databricks workspace URL"
}

output "network_id" {
  value       = local.emit_mws_networks ? databricks_mws_networks.this[0].network_id : null
  description = "mws_networks ID (null when databricks_managed)"
}

output "frontend_endpoint_id" {
  value       = var.enable_frontend && var.frontend_psc_fr_id != null ? databricks_mws_vpc_endpoint.frontend[0].vpc_endpoint_id : null
  description = "Frontend mws_vpc_endpoint ID (null when no PSC)"
}

output "backend_endpoint_id" {
  value       = var.enable_backend && var.backend_psc_fr_id != null ? databricks_mws_vpc_endpoint.backend[0].vpc_endpoint_id : null
  description = "Backend mws_vpc_endpoint ID (null when no PSC)"
}

output "transit_endpoint_id" {
  value       = var.enable_frontend && var.hub_frontend_psc_fr_id != null ? databricks_mws_vpc_endpoint.transit[0].vpc_endpoint_id : null
  description = "Hub-side mws_vpc_endpoint ID (null when no hub)"
}
