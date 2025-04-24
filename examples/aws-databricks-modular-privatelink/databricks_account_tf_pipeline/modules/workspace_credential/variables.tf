variable "region" {
  type        = string
  description = "AWS region"
}

variable "aws_account_id" {
  type        = string
  description = "AWS account ID"
}

variable "databricks_account_id" {
  type        = string
  description = "Databricks account ID"
}

variable "resource_prefix" {
  type        = string
  description = "Resource prefix"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "security_group_id" {
  type        = string
  description = "Security group ID"
}
