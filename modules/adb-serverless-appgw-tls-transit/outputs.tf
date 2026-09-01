output "appgw_id" {
  description = "Resource ID of the Application Gateway."
  value       = azapi_resource.appgw.id
}

output "appgw_name" {
  description = "Application Gateway name."
  value       = azapi_resource.appgw.name
}

output "appgw_frontend_config_name" {
  description = "Private frontend configuration name used as the NCC rule group_id."
  value       = local.frontend_name
}

output "appgw_frontend_private_ip" {
  description = "Private IP of the Application Gateway listener frontend."
  value       = local.appgw_frontend_private_ip
}

output "ncc_id" {
  description = "Databricks NCC ID."
  value       = databricks_mws_network_connectivity_config.this.network_connectivity_config_id
}

output "transit_vnet_id" {
  description = "Transit VNet ID."
  value       = azurerm_virtual_network.this.id
}

output "serverless_domain_names" {
  description = "FQDNs registered in the NCC private endpoint rule."
  value       = var.serverless_domain_names
}
