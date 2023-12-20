variable "tags" {
  type        = map(string)
  description = "(Required) Map of tags to be applied to the kinesis stream"
}

variable "prefix" {
  type        = string
  description = "(Required) Prefix for the resources deployed by this module"
}

variable "cidr_block" {
  type        = string
  description = "(Required) CIDR block for the VPC that will be used to create the Databricks workspace"
}

variable "region" {
  type        = string
  description = "(Required) AWS region where the resources will be deployed"
}

variable "roles_to_assume" {
  type        = list(string)
  description = "(Optional) List of AWS roles that the cross account role can pass to the clusters (important when creating instance profiles)"
}

variable "databricks_account_id" {
  type        = string
  description = "(Required) Databricks Account ID"
}
