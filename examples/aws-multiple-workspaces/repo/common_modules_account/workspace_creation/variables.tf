variable "databricks_account_id" {
  type        = string
}

variable "region" {
  type        = string
}

variable "cross_account_role_arn" {
  type        = string
}

variable "resource_prefix" {
  type        = string
}

variable "bucket_name" {
  type        = string
}

variable "security_group_ids" {
  type        = list(any)
}

variable "subnet_ids" {
  type        = list(any)
}

variable "vpc_id" {
  type        = string
}