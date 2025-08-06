variable "resource_prefix" {
  type        = string
  description = "Prefix for resource names"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where security groups will be created"
}

variable "sg_ingress_protocol" {
  type        = list(string)
  description = "List of protocols for ingress rules"
}

variable "sg_egress_protocol" {
  type        = list(string)
  description = "List of protocols for egress rules"
}

variable "sg_egress_ports" {
  type        = list(number)
  description = "List of ports for egress rules"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
}

variable "cross_account_role_arn" {
  type        = string
  description = "ARN of the cross-account role for KMS key policies"
}

variable "cmk_admin" {
  type        = string
  description = "ARN of the user who will be the admin for CMK keys"
}

variable "region" {
  type        = string
  description = "AWS region for KMS key naming"
}