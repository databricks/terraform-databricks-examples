locals {
  databricks_allowed_principal = "arn:aws:iam::565502421330:role/private-connectivity-role-${var.region}"
}

variable "region" {
  type        = string
  default     = "us-east-1"
  description = "The region of the cloud service"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]{4,9}-[0-9]$", var.region))
    error_message = "The region must be a valid AWS region (e.g. us-east-1)"
  }
}

variable "prefix" {
  type        = string
  default     = "pl"
  description = "The prefix to use for the resources"

  validation {
    condition     = length(var.prefix) <= 5
    error_message = "The prefix must be less than 5 characters"
  }
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC to deploy the resources into"
  validation {
    condition     = can(regex("^vpc-[0-9a-z]+$", var.vpc_id))
    error_message = "The VPC ID must be a valid VPC ID"
  }
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "The private subnet IDs to use for the resources"

  validation {
    condition     = length(var.private_subnet_ids) > 0
    error_message = "Must provide at least one private subnet ID"
  }

  validation {
    condition = alltrue([
      for subnet_id in var.private_subnet_ids : can(regex("^subnet-[0-9a-z]+$", subnet_id))
    ])
    error_message = "The private subnet IDs must be a list of valid subnet IDs"
  }
}

variable "network_connectivity_config_id" {
  type        = string
  description = "The network connectivity config ID to use for the resources"

  validation {
    condition     = length(var.network_connectivity_config_id) > 0
    error_message = "Must provide a network connectivity config ID"
  }
}

variable "aws_service" {
  type        = string
  description = "The AWS service to connect to (e.g. secretsmanager, lambda, etc.)"

  validation {
    condition     = length(var.aws_service) > 0
    error_message = "Must provide an AWS service"
  }

  validation {
    condition     = !contains(["com.amazonaws"], var.aws_service)
    error_message = "Do not provide the FQDN. The service name will be interpolated to: com.amazonaws.<region>.<aws_service>"
  }
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
  description = "The CIDR blocks to allow inbound traffic from."
  default = [
    # Serverless Egress PrivateLink
    "172.18.0.0/16",
    "10.0.0.0/8",
  ]
}