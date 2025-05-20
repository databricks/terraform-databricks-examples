variable "resource_prefix" {
  description = "Prefix for all resources"
  type        = string
}

variable "tags" {
  description = "Tags for all resources"
  type        = map(string)
}

variable "databricks_account_id" {
  description = "Databricks account ID"
  type        = string
}

