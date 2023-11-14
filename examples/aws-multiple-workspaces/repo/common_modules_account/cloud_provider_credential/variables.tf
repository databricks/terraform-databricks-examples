variable "aws_account_id" {
  type        = string
}

variable "databricks_account_id" {
  type        = string
}

variable "resource_prefix" {
  type        = string
}

variable "region" {
  type        = string
}

variable "vpc_id" {
  type        = string
}

variable "security_group_ids" {
  type        = list(string)
}



