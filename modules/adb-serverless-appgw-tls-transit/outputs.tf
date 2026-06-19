output "appgw_id" {
  description = "Resource ID of the Application Gateway."
  value       = azapi_resource.appgw.id
}

output "appgw_name" {
  description = "Name of the Application Gateway."
  value       = var.appgw_name
}

output "appgw_frontend_config_name" {
  description = "Frontend IP configuration name that carries the Private Link config — this is the group_id used by the NCC private endpoint rule."
  value       = local.frontend_pl_name
}

output "public_ip_address" {
  description = "Public IP of the Application Gateway (required by the Standard_v2 SKU)."
  value       = azurerm_public_ip.appgw.ip_address
}

output "ncc_id" {
  description = "Databricks Network Connectivity Configuration ID."
  value       = databricks_mws_network_connectivity_config.this.network_connectivity_config_id
}

output "serverless_domain_names" {
  description = "FQDNs registered in the NCC rule. Serverless clients dial these; NCC injects DNS to the Databricks-managed private endpoint."
  value       = var.serverless_domain_names
}

output "transit_vnet_id" {
  description = "Resource ID of the transit VNet (peer your target service's network to this, or place a private endpoint here)."
  value       = azurerm_virtual_network.transit.id
}
