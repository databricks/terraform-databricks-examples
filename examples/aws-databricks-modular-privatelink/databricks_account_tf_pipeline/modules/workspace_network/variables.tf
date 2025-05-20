variable "resource_prefix" {
  type = string
}

variable "databricks_account_id" {
  type = string
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs, e.g. [subnet-0123456789abcdefg, subnet-0123456789abcdefh]"
}

variable "security_group_id" {
  type        = string
  description = "Security group ID"
}

variable "workspace_endpoint_id" {
  type        = string
  description = "Workspace endpoint ID"
}

variable "scc_relay_endpoint_id" {
  type        = string
  description = "SCC relay endpoint ID"
}
