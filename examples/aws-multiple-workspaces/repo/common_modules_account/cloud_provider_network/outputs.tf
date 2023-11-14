output "cloud_provider_network_vpc" {
  value = module.vpc.vpc_id
}

output "cloud_provider_network_subnets" {
  value = module.vpc.private_subnets
}

output "cloud_provider_network_security_groups" {
  value = [aws_security_group.sg.id]
}