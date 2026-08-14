variable "tags" {
  default     = {}
  type        = map(string)
  description = "(Optional) Tags to add to created resources"
}

variable "prefix" {
  type        = string
  description = "(Required) Prefix for resource naming"
}

variable "region" {
  type        = string
  description = "(Required) AWS region to deploy to"
}

variable "aws_profile" {
  type        = string
  default     = null
  description = "(Optional) AWS CLI profile name for authentication"
}

variable "aws_account_id" {
  type        = string
  description = "(Required) AWS Account ID"
}

variable "databricks_account_id" {
  type        = string
  description = "(Required) Databricks Account ID"
}

variable "databricks_host" {
  type        = string
  description = "(Required) Databricks workspace URL (e.g., https://xxx.cloud.databricks.com)"
}

variable "databricks_client_id" {
  type        = string
  description = "(Required) Databricks service principal client ID"
}

variable "databricks_client_secret" {
  type        = string
  sensitive   = true
  description = "(Required) Databricks service principal client secret"
}


variable "databricks_pat_token" {
  type        = string
  sensitive   = true
  description = "(Required) Databricks service principal client secret"
}

