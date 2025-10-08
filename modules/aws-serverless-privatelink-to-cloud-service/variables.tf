locals {
  databricks_allowed_principal = "arn:aws:iam::565502421330:role/private-connectivity-role-${var.region}"

  vpce_eni_ips = flatten([
    for interface_id in aws_vpc_endpoint.aws_service.network_interface_ids :
    data.aws_network_interface.aws_service[interface_id].private_ip
  ])
}

variable "region" {
  type        = string
  default     = "us-east-1"
  description = "The region of the cloud service"
}

variable "prefix" {
  type        = string
  default     = "pl-demo"
  description = "The prefix to use for the resources"
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "The private subnet IDs to use for the resources"
}

variable "network_connectivity_config_id" {
  type        = string
  description = "The network connectivity config ID to use for the resources"
}

variable "aws_service" {
  type        = string
  description = "The AWS service to connect to (e.g. secretsmanager, lambda, etc.)"
}

variable "private_dns_name" {
  type        = string
  description = "The private DNS name to use for the resources"
  default     = null
}

variable "allowed_ingress_security_groups" {
  type        = set(string)
  description = "The security groups to allow inbound traffic from"
  default     = null
}

variable "allowed_ingress_cidr_blocks" {
  type        = list(string)
  description = "The CIDR blocks to allow inbound traffic from. If empty, the VPC's CIDR block will be used."
  default     = []
}