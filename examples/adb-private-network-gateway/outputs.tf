output "network_connectivity_config_id" {
  description = "ID of the NCC that owns the gateway."
  value       = databricks_mws_network_connectivity_config.this.network_connectivity_config_id
}

output "gateway_name" {
  description = "Full resource name of the private network gateway."
  value       = module.private_network_gateway.gateway_name
}

output "gateway_id" {
  description = "ID of the private network gateway."
  value       = module.private_network_gateway.gateway_id
}

output "gateway_state" {
  description = "Gateway state: CREATING, ESTABLISHED or FAILED."
  value       = module.private_network_gateway.gateway_state
}

output "gateway_subnet_id" {
  description = "Resource ID of the delegated gateway subnet."
  value       = module.private_network_gateway.gateway_subnet_id
}

output "nat_public_ip" {
  description = "Static egress IP of the NAT gateway. Serverless internet egress uses it in ALL_TRAFFIC mode when attach_nat_gateway is true."
  value       = azurerm_public_ip.nat.ip_address
}
