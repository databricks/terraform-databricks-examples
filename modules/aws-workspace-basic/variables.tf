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
  description = ""
  type        = string
  default     = "10.4.0.0/16"
}

variable "region" {
  default     = "eu-west-2"
  type        = string
  description = "AWS region to deploy to"
}

variable "prefix" {
  default     = ""
  type        = string
  description = "Prefix for use in the generated names"
}
