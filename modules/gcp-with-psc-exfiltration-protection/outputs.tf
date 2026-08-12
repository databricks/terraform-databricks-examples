# Workspace
output "workspace_url" {
  description = "The workspace URL which is of the format '{workspaceId}.{random}.gcp.databricks.com'"
  value       = databricks_mws_workspaces.databricks_workspace.workspace_url
}

output "workspace_id" {
  description = "The Databricks workspace ID"
  value       = databricks_mws_workspaces.databricks_workspace.workspace_id
}

# Network
output "spoke_vpc_id" {
  description = "The ID of the Spoke VPC network"
  value       = google_compute_network.spoke_vpc.id
}

output "hub_vpc_id" {
  description = "The ID of the Hub VPC network"
  value       = google_compute_network.hub_vpc.id
}

output "spoke_subnetwork_id" {
  description = "The ID of the primary Spoke subnet"
  value       = google_compute_subnetwork.spoke_subnetwork.id
}

output "psc_subnetwork_id" {
  description = "The ID of the PSC subnet within the Spoke VPC"
  value       = google_compute_subnetwork.psc_subnetwork.id
}

output "network_id" {
  description = "The Databricks MWS network configuration ID"
  value       = databricks_mws_networks.databricks_network.network_id
}

# PSC Endpoints
output "backend_psc_endpoint_ip" {
  description = "The IP address of the backend (SCC) PSC endpoint"
  value       = google_compute_address.backend_pe_ip_address.address
}

output "spoke_frontend_psc_endpoint_ip" {
  description = "The IP address of the workspace frontend PSC endpoint in the Spoke VPC"
  value       = google_compute_address.spoke_frontend_pe_ip_address.address
}

output "hub_frontend_psc_endpoint_ip" {
  description = "The IP address of the workspace frontend PSC endpoint in the Hub VPC"
  value       = google_compute_address.hub_frontend_pe_ip_address.address
}
