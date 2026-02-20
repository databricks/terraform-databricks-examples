variable "tags" {
  type        = map(string)
  description = "(Optional) Tags to be propagated across all AWS resources"
  default     = {}
}

variable "prefix" {
  type        = string
  description = "(Required) Prefix to name the resources created by this module"
}

variable "region" {
  type        = string
  description = "(Required) AWS region where the assets will be deployed"
}

variable "aws_account_id" {
  type        = string
  description = "(Required) AWS account ID where the IAM role will be created"
}

variable "databricks_account_id" {
  type        = string
  description = "(Required) Databricks Account ID"
}

variable "create_bucket" {
  type        = bool
  description = "(Optional) Whether to create a new S3 bucket or use an existing one"
  default     = true
}

variable "existing_bucket_name" {
  type        = string
  description = "(Optional) Name of existing S3 bucket when create_bucket is false"
  default     = null
}

variable "bucket_name" {
  type        = string
  description = "(Optional) Name for the S3 bucket. If not provided, uses prefix-file-events"
  default     = null
}

variable "s3_path_prefix" {
  type        = string
  description = "(Optional) Path prefix within the S3 bucket for the external location"
  default     = ""
}

variable "force_destroy_bucket" {
  type        = bool
  description = "(Optional) Allow bucket destruction even with objects inside"
  default     = false
}

variable "external_location_name" {
  type        = string
  description = "(Optional) Name for the external location. If not provided, uses prefix-file-events-location"
  default     = null
}

variable "storage_credential_name" {
  type        = string
  description = "(Optional) Name for the storage credential. If not provided, uses prefix-file-events-credential"
  default     = null
}

variable "create_catalog" {
  type        = bool
  description = "(Optional) Whether to create a catalog using this external location"
  default     = false
}

variable "catalog_name" {
  type        = string
  description = "(Optional) Name for the catalog. Required if create_catalog is true"
  default     = null
}

variable "catalog_owner" {
  type        = string
  description = "(Optional) Owner of the catalog"
  default     = null
}

variable "catalog_isolation_mode" {
  type        = string
  description = "(Optional) Isolation mode for the catalog (OPEN or ISOLATED)"
  default     = "OPEN"

  validation {
    condition     = contains(["OPEN", "ISOLATED"], var.catalog_isolation_mode)
    error_message = "catalog_isolation_mode must be either OPEN or ISOLATED"
  }
}

variable "external_location_grants" {
  type = list(object({
    principal  = string
    privileges = list(string)
  }))
  description = "(Optional) List of grants for the external location"
  default     = []
}

variable "storage_credential_grants" {
  type = list(object({
    principal  = string
    privileges = list(string)
  }))
  description = "(Optional) List of grants for the storage credential"
  default     = []
}

variable "catalog_grants" {
  type = list(object({
    principal  = string
    privileges = list(string)
  }))
  description = "(Optional) List of grants for the catalog (if created)"
  default     = []
}

locals {
  bucket_name             = var.create_bucket ? (var.bucket_name != null ? var.bucket_name : "${var.prefix}-file-events") : var.existing_bucket_name
  external_location_name  = var.external_location_name != null ? var.external_location_name : "${var.prefix}-file-events-location"
  storage_credential_name = var.storage_credential_name != null ? var.storage_credential_name : "${var.prefix}-file-events-credential"
  iam_role_name           = "${var.prefix}-file-events-access"
  iam_role_arn            = "arn:aws:iam::${var.aws_account_id}:role/${local.iam_role_name}"
  s3_url                  = var.s3_path_prefix != "" ? "s3://${local.bucket_name}/${var.s3_path_prefix}" : "s3://${local.bucket_name}"
}
