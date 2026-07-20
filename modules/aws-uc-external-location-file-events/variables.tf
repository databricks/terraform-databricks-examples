variable "name_prefix" {
  type        = string
  description = "Prefix used to derive default names for the IAM role, IAM policy, and storage credential."
}

variable "databricks_account_id" {
  type        = string
  description = "Databricks account ID. Used as the sts:ExternalId in the IAM role trust policy (the Unity Catalog storage credential external ID)."
}

variable "uc_master_role_arn" {
  type        = string
  description = "ARN of the Unity Catalog AWS master role that assumes the storage credential role. Defaults to the Databricks commercial (non-GovCloud) UC master role."
  default     = "arn:aws:iam::414351767826:role/unity-catalog-prod-UCMasterRole-14S5ZJVKOTYTL"
}

variable "bucket_names" {
  type        = list(string)
  description = "Names of the S3 buckets that the storage credential IAM role is granted access to (and, when file events are enabled, allowed to configure notifications on). The buckets must already exist; this module does not create them."

  validation {
    condition     = length(var.bucket_names) > 0
    error_message = "At least one bucket name is required."
  }
}

variable "external_locations" {
  type = list(object({
    name      = string
    url       = string
    comment   = optional(string, "Managed by Terraform")
    read_only = optional(bool, false)
  }))
  description = "External locations to create. Each location has managed SQS file events enabled when enable_file_events is true."

  validation {
    condition     = length(var.external_locations) > 0
    error_message = "At least one external location is required."
  }
}

variable "enable_file_events" {
  type        = bool
  description = "Enable automatic managed file events (SNS topic + SQS queue + S3 bucket notification, csms-* prefixed) on every external location. Adds the required sns/sqs/bucket-notification permissions to the IAM policy."
  default     = true
}

variable "create_storage_credential" {
  type        = bool
  description = "When true, create a storage credential backed by the IAM role this module manages. When false, reuse existing_credential_name (the IAM role/policy are still managed)."
  default     = true
}

variable "existing_credential_name" {
  type        = string
  description = "Name of an existing storage credential to reference on the external locations when create_storage_credential is false."
  default     = ""

  validation {
    condition     = var.create_storage_credential || var.existing_credential_name != ""
    error_message = "existing_credential_name must be set when create_storage_credential is false."
  }
}

variable "storage_credential_name" {
  type        = string
  description = "Name for the created storage credential. Defaults to \"<name_prefix>-storage-credential\"."
  default     = ""
}

variable "storage_credential_comment" {
  type        = string
  description = "Comment applied to the created storage credential."
  default     = "Storage credential for external locations with file events. Managed by Terraform."
}

variable "iam_role_name" {
  type        = string
  description = "Name of the IAM role used by the storage credential. Defaults to \"<name_prefix>-uc\"."
  default     = ""
}

variable "iam_policy_name" {
  type        = string
  description = "Name of the IAM policy attached to the role. Defaults to \"<iam_role_name>-policy\"."
  default     = ""
}

variable "iam_propagation_delay" {
  type        = string
  description = "Delay to wait after creating the IAM role/policy before creating the storage credential and external locations, so IAM changes propagate (avoids \"non self-assuming\" / 403 validation errors). Set to \"\" to disable the wait (e.g. when the role already exists)."
  default     = "60s"
}

variable "force_destroy" {
  type        = bool
  description = "Force destroy the storage credential and external locations even if dependents exist."
  default     = false
}

variable "credential_grants" {
  type = list(object({
    principal  = string
    privileges = list(string)
  }))
  description = "UC grants applied to the storage credential. Defaults to empty (owner-only)."
  default     = []
}

variable "location_grants" {
  type = list(object({
    principal  = string
    privileges = list(string)
  }))
  description = <<-EOT
    UC grants applied to every external location.
    Recommended privileges for data engineers: BROWSE, READ_FILES, WRITE_FILES,
    CREATE_EXTERNAL_TABLE, CREATE_EXTERNAL_VOLUME.
  EOT
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to the IAM role and policy."
  default     = {}
}
