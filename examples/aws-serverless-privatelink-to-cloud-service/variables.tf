variable "databricks_account_client_id" {
  type        = string
  description = "Application ID of account-level service principal"
}

variable "databricks_account_client_secret" {
  type        = string
  description = "Client secret of account-level service principal"
  sensitive   = true
}

variable "databricks_account_id" {
  type        = string
  description = "Databricks Account ID"
}

variable "tags" {
  default     = {}
  type        = map(string)
  description = "Optional tags to add to created resources"
}

variable "region" {
  type        = string
  default     = "us-east-1"
  description = "The region to deploy to."
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC to deploy the resources into"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "The private subnet IDs to use for the resources"
}

variable "network_connectivity_config_id" {
  type        = string
  description = "The network connectivity config ID to use for the resources"
}