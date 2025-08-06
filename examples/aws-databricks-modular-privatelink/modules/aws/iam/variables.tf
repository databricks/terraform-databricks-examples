variable "databricks_account_id" {
  type        = string
  description = "Databricks Account ID"
}

variable "resource_prefix" {
  type        = string
  description = "Prefix for resource names"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
}