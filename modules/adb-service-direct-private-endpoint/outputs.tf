output "private_endpoint_id" {
  description = "Resource ID of the Azure private endpoint."
  value       = azurerm_private_endpoint.this.id
}

output "private_endpoint_name" {
  description = "Name of the Azure private endpoint."
  value       = azurerm_private_endpoint.this.name
}

output "private_endpoint_resource_guid" {
  description = "properties.resourceGuid of the private endpoint (read via azapi; consumed by the account-side registration)."
  value       = local.pe_resource_guid
}

output "private_ip_address" {
  description = "Private IP assigned to the private endpoint."
  value       = local.pe_private_ip
}

output "dns_fqdn" {
  description = "Resolvable FQDN clients use for service-direct (<region>.service-direct.privatelink.azuredatabricks.net)."
  value       = "${local.a_record_name}.${var.private_dns_zone_name}"
}

output "endpoint_id" {
  description = "Databricks endpoint_id of the registration."
  value       = databricks_endpoint.this.endpoint_id
}

output "endpoint_state" {
  description = "State of the registered endpoint. Must be APPROVED to be usable."
  value       = databricks_endpoint.this.state
}

output "endpoint_use_case" {
  description = "use_case of the registered endpoint — expected SERVICE_DIRECT."
  value       = databricks_endpoint.this.use_case
}
