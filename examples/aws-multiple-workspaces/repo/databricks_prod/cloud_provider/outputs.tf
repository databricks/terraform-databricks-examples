output "cloud_provider_credential" {
  value = module.cloud_provider_credential.cloud_provider_credential
}

output "cloud_provider_network_vpc" {
  value = module.cloud_provider_network.cloud_provider_network_vpc
}

output "cloud_provider_network_subnets" {
  value = module.cloud_provider_network.cloud_provider_network_subnets
}

output "cloud_provider_network_security_groups" {
  value = module.cloud_provider_network.cloud_provider_network_security_groups
}

output "cloud_provider_storage" {
  value = module.cloud_provider_storage.cloud_provider_storage
}