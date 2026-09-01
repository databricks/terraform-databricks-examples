variable "aws_region" {
  type        = string
  description = "AWS region for the S3 bucket"
  default     = "us-east-1"
}

variable "aws_profile" {
  type        = string
  description = "AWS CLI profile for the account that owns the bucket. Leave empty to use the default credential chain / env vars."
  default     = ""
}

variable "databricks_profile" {
  type        = string
  description = "Databricks CLI profile for a workspace assigned to the target metastore. Leave empty to use DATABRICKS_* env vars."
  default     = ""
}

variable "databricks_account_id" {
  type        = string
  description = "Databricks account ID (used as the sts:ExternalId in the IAM role trust policy)."
}

variable "name_prefix" {
  type        = string
  description = "Prefix for UC object and IAM names"
  default     = "file-events-demo"
}

variable "bucket_name" {
  type        = string
  description = "Globally unique S3 bucket name to create for the external location"
}

variable "external_location_name" {
  type        = string
  description = "Name of the Unity Catalog external location"
  default     = "file_events_landing"
}

variable "external_location_prefix" {
  type        = string
  description = "Prefix within the bucket managed by the external location"
  default     = "landing"
}

variable "grant_principal" {
  type        = string
  description = "UC group or user to grant on the credential and external location. Leave empty to skip grants."
  default     = ""
}
