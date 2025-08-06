output "backend_rest_vpce_id" {
  value = databricks_mws_vpc_endpoint.backend_rest_vpce.vpc_endpoint_id
}

output "relay_vpce_id" {
  value = databricks_mws_vpc_endpoint.relay.vpc_endpoint_id
}