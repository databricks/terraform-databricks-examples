variable "resource_prefix" {
  type        = string
  description = "Prefix for resource names"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where endpoints will be created"
}

variable "privatelink_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for PrivateLink endpoints"
}

variable "privatelink_security_group_id" {
  type        = string
  description = "Security group ID for PrivateLink endpoints"
}

variable "workspace_vpce_service" {
  type        = string
  description = "Workspace VPC endpoint service name"
}

variable "relay_vpce_service" {
  type        = string
  description = "Relay VPC endpoint service name"
}

variable "databricks_account_id" {
  type        = string
  description = "Databricks Account ID"
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
}