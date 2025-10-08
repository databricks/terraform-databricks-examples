output "nlb_arn" {
  description = "The ARN of the NLB"
  value       = aws_lb.this.arn
}


output "vpce_ips" {
  description = "Private IP addresses of the VPCE ENI; useful if you are using this for an NLB target group."
  value = aws_vpc_endpoint.aws_service != null ? flatten([
    for interface_id in aws_vpc_endpoint.aws_service.network_interface_ids :
    data.aws_network_interface.aws_service[interface_id].private_ip
  ]) : []
}

output "vpce_sg_id" {
  description = "Security Group ID of the VPCE"
  value       = aws_security_group.this.id
}

output "vpc_endpoint_id" {
  description = "ID of the VPCE created by Databricks"
  value       = databricks_mws_ncc_private_endpoint_rule.this.vpc_endpoint_id
}