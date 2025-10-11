output "nlb_arn" {
  description = "The ARN of the NLB"
  value       = aws_lb.this.arn
}


output "vpce_ips" {
  description = "Private IP addresses of the VPCE ENI; useful if you are using this for an NLB target group."
  value = [
    for idx in range(length(var.private_subnet_ids)) : data.aws_network_interface.aws_service[idx].private_ip
  ]
}

output "vpce_sg_id" {
  description = "Security Group ID of the VPCE"
  value       = aws_security_group.this.id
}

output "vpc_endpoint_id" {
  description = "ID of the VPCE created by Databricks"
  value       = databricks_mws_ncc_private_endpoint_rule.this.vpc_endpoint_id
}

output "private_dns_verification_records" {
  description = "The private DNS verification records you need to add to your DNS provider"
  value       = aws_vpc_endpoint_service.private_link_service.private_dns_name_configuration
}

output "vpce_service_id" {
  description = "ID of the VPCE Service that you need to accept the connection request on"
  value       = aws_vpc_endpoint_service.private_link_service.id
}