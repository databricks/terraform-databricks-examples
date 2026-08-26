output "appgw_id" {
  description = "Resource ID of the Application Gateway."
  value       = module.adb-serverless-appgw-tls-transit.appgw_id
}

output "appgw_frontend_config_name" {
  description = "Frontend configuration name used as the NCC rule group_id."
  value       = module.adb-serverless-appgw-tls-transit.appgw_frontend_config_name
}

output "ncc_id" {
  description = "Databricks NCC ID."
  value       = module.adb-serverless-appgw-tls-transit.ncc_id
}

output "serverless_domain_names" {
  description = "FQDNs registered in the NCC private endpoint rule."
  value       = module.adb-serverless-appgw-tls-transit.serverless_domain_names
}

output "transit_vnet_id" {
  description = "Transit VNet ID. Peer the target service network here or place a private endpoint in it."
  value       = module.adb-serverless-appgw-tls-transit.transit_vnet_id
}
