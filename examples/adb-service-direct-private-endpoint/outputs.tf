output "private_endpoint_name" {
  description = "Name of the Azure private endpoint."
  value       = module.adb-service-direct-private-endpoint.private_endpoint_name
}

output "private_ip_address" {
  description = "Private IP assigned to the private endpoint."
  value       = module.adb-service-direct-private-endpoint.private_ip_address
}

output "dns_fqdn" {
  description = "Resolvable FQDN for service-direct (<region>.service-direct.privatelink.azuredatabricks.net)."
  value       = module.adb-service-direct-private-endpoint.dns_fqdn
}

output "endpoint_state" {
  description = "Account-side endpoint state. Must be APPROVED to be usable."
  value       = module.adb-service-direct-private-endpoint.endpoint_state
}

output "endpoint_use_case" {
  description = "Endpoint use_case — expected SERVICE_DIRECT."
  value       = module.adb-service-direct-private-endpoint.endpoint_use_case
}
