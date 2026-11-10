output "gateway_name" {
  description = "Full resource name of the gateway: accounts/<account_id>/network-connectivity-configs/<ncc_id>/private-network-gateways/<gateway_id>."
  value       = databricks_private_network_gateway.this.name
}

output "gateway_id" {
  description = "ID of the gateway (last segment of gateway_name)."
  value       = element(split("/", databricks_private_network_gateway.this.name), length(split("/", databricks_private_network_gateway.this.name)) - 1)
}

output "gateway_state" {
  description = "Gateway state reported by the API: CREATING, ESTABLISHED or FAILED. FAILED is terminal: delete and recreate the gateway."
  value       = databricks_private_network_gateway.this.state
}

output "gateway_error_message" {
  description = "Error message reported by the API when the gateway is FAILED."
  value       = databricks_private_network_gateway.this.error_message
}

output "gateway_subnet_id" {
  description = "Resource ID of the delegated gateway subnet."
  value       = azurerm_subnet.gateway.id
}
