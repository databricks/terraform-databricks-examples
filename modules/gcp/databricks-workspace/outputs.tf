# === Workspace ===========================================================
output "workspace_id" {
  value       = module.workspace.workspace_id
  description = "Databricks workspace ID"
}

output "workspace_url" {
  value       = module.workspace.workspace_url
  description = "Databricks workspace URL (https://<id>.<random>.gcp.databricks.com)"
}

output "network_id" {
  value       = module.workspace.network_id
  description = "databricks_mws_networks ID (null when vpc_source=databricks_managed)"
}

output "private_access_settings_id" {
  value       = module.workspace.private_access_settings_id
  description = "databricks_mws_private_access_settings ID (null when private_access_only=false)"
}

output "serverless_network_policy_id" {
  value       = module.workspace.serverless_network_policy_id
  description = "Serverless egress network-policy ID bound to the workspace (null when serverless_egress_mode=unmanaged)"
}

# === mws_vpc_endpoint IDs (Databricks-side PSC registration) ============
output "frontend_endpoint_id" {
  value       = module.workspace.frontend_endpoint_id
  description = "Frontend mws_vpc_endpoint ID (null when private_link_frontend=false)"
}

output "backend_endpoint_id" {
  value       = module.workspace.backend_endpoint_id
  description = "Backend (SCC) mws_vpc_endpoint ID (null when private_link_backend=false)"
}

output "transit_endpoint_id" {
  value       = module.workspace.transit_endpoint_id
  description = "Hub-side mws_vpc_endpoint ID (null when no hub or no frontend PSC)"
}

# === Network =============================================================
output "spoke_vpc_id" {
  value       = local.databricks_managed ? null : module.network[0].spoke_vpc_id
  description = "Spoke VPC ID (null when vpc_source=databricks_managed)"
}

output "spoke_vpc_self_link" {
  value       = local.databricks_managed ? null : module.network[0].spoke_vpc_self_link
  description = "Spoke VPC self-link (null when vpc_source=databricks_managed)"
}

output "spoke_subnet_id" {
  value       = local.databricks_managed ? null : module.network[0].spoke_subnet_id
  description = "Spoke subnet ID (null when vpc_source=databricks_managed)"
}

output "spoke_subnet_self_link" {
  value       = local.databricks_managed ? null : module.network[0].spoke_subnet_self_link
  description = "Spoke subnet self-link (null when vpc_source=databricks_managed)"
}

output "hub_vpc_id" {
  value       = local.dns_enabled ? module.network[0].hub_vpc_id : null
  description = "Hub VPC ID (null when restricted_egress=false)"
}

output "hub_vpc_self_link" {
  value       = local.dns_enabled ? module.network[0].hub_vpc_self_link : null
  description = "Hub VPC self-link (null when restricted_egress=false)"
}

output "nat_id" {
  value       = local.create_spoke && !var.restricted_egress ? module.network[0].nat_id : null
  description = "Cloud NAT ID (null when vpc_source != create or when restricted_egress=true)"
}

# === Private connectivity ===============================================
output "frontend_psc_ip_spoke" {
  value       = local.private_connectivity_enabled ? module.private_connectivity[0].frontend_psc_ip_spoke : null
  description = "IP address of the spoke-side frontend PSC endpoint (null when no PSC)"
}

output "backend_psc_ip_spoke" {
  value       = local.private_connectivity_enabled ? module.private_connectivity[0].backend_psc_ip_spoke : null
  description = "IP address of the spoke-side backend PSC endpoint (null when no PSC)"
}

output "frontend_psc_ip_hub" {
  value       = local.private_connectivity_enabled ? module.private_connectivity[0].frontend_psc_ip_hub : null
  description = "IP address of the hub-side frontend PSC endpoint (null when restricted_egress=false)"
}

# === Identifiers ========================================================
output "suffix" {
  value       = random_string.suffix.result
  description = "Random suffix used in resource names (useful when wiring downstream modules)"
}

output "google_region" {
  value       = var.google_region
  description = "Region the workspace was deployed to (echo of input; convenient for downstream modules)"
}
