variable "databricks_account_id" {
  type        = string
  description = "Databricks Account ID"
}

variable "tags" {
  default     = {}
  type        = map(string)
  description = "Optional tags to add to created resources"
}

variable "cidr_block" {
  description = "IP range for AWS VPC"
  type        = string
  default     = "10.4.0.0/16"
}

variable "region" {
  default     = "eu-west-1"
  type        = string
  description = "AWS region to deploy to"
}
