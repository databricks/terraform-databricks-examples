output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "workspace_security_group_ids" {
  value = aws_security_group.sg[*].id
}

output "privatelink_security_group_ids" {
  value = aws_security_group.privatelink.id
}

output "workspace_endpoint_id" {
  value = aws_vpc_endpoint.backend_rest.id
}

output "scc_relay_endpoint_id" {
  value = aws_vpc_endpoint.backend_relay.id
}
