variable "aws_account_id" {}

variable "tags" {
  type        = map(any)
  description = "(Optional) List of tags to be propagated accross all assets in this demo"
}

variable "prefix" {
  type        = string
  description = "(Optional) Prefix to name the resources created by this module"
}

variable "region" {
  type        = string
  description = "(Required) AWS region where the assets will be deployed"
}

variable "databricks_account_id" {
  type        = string
  description = "(Required) Databricks Account ID"
}

variable "databricks_workspace_ids" {
  description = <<EOT
  List of Databricks workspace IDs to be enabled with Unity Catalog.
  Enter with square brackets and double quotes
  e.g. ["111111111", "222222222"]
  EOT
  type        = list(string)
  default     = []
}

variable "unity_metastore_owner" {
  description = "(Required) Name of the principal that will be the owner of the Metastore"
  type        = string
}

variable "metastore_name" {
  description = "(Optional) Name of the metastore that will be created"
  type        = string
  default     = null
}

locals {
  metastore_name = var.metastore_name == null ? "${var.prefix}-metastore" : var.metastore_name
}
