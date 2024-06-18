variable "tags" {
  default     = {}
  type        = map(string)
  description = "(Optional) Optional tags to add to created resources"
}

variable "workspace_name" {
  type        = string
  default     = ""
  description = "(Optional) Workspace Name for this module - if none are provided, the prefix will be used to name the workspace via coalesce()"
}

variable "prefix" {
  default     = "demo"
  type        = string
  description = "(Optional) Prefix for use in the generated names"
}

variable "region" {
  type        = string
  description = "(Required) AWS region where the assets will be deployed"
}

variable "vpc_id" {
  type        = string
  description = "(Required) AWS VPC ID"
}

variable "security_group_ids" {
  type        = list(string)
  description = "(Required) List of VPC network security group IDs"
}

variable "vpc_private_subnets" {
  type        = list(string)
  description = "(Required) AWS VPC Subnets where the Databricks workspace will be deployed"
}

variable "databricks_account_id" {
  type        = string
  description = "(Required) Databricks Account ID"
}

variable "cross_account_role_arn" {
  type        = string
  description = "(Required) AWS cross account role ARN that will be used for the Databricks workspace"
}

variable "root_storage_bucket" {
  type        = string
  description = "(Required) AWS root storage bucket"
}
