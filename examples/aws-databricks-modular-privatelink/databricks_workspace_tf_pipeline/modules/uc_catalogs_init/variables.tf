variable "s3_bucket_name" {
  type        = string
  description = "Name of the S3 bucket."
}

variable "iam_role_name" {
  type        = string
  description = "IAM role name for Databricks Unity Catalog."
}

variable "storage_credential_name" {
  type        = string
  description = "Databricks Unity Catalog storage credential name."
}

variable "external_location_name" {
  type        = string
  description = "Databricks Unity Catalog external location name."
}

variable "catalog_name" {
  type        = string
  description = "Databricks Unity Catalog catalog name."
}

