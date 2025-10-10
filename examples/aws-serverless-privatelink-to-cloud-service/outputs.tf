output "private_dns_verification_records" {
  value = module.pl-secretsmanager.private_dns_verification_records
}

output "vpce_service_id" {
  value = module.pl-secretsmanager.vpce_service_id
}