variable "name_prefix" {
  type        = string
  description = "Prefix used for storage credential and external location names"
}

variable "access_connector_id" {
  type        = string
  description = "Azure resource ID of the Access Connector for Azure Databricks (managed identity used by the storage credential)"
}

variable "storage_account_id" {
  type        = string
  description = "Azure resource ID of the ADLS Gen2 storage account that backs the external location(s)"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group that contains the storage account (used for managed AQS and Event Grid RBAC)"
}

variable "subscription_id" {
  type        = string
  description = "Azure subscription ID for managed AQS file-event configuration. Defaults to the current azurerm client subscription when empty."
  default     = ""
}

variable "external_locations" {
  type = list(object({
    name      = string
    url       = string
    comment   = optional(string, "Managed by Terraform")
    read_only = optional(bool, false)
  }))
  description = "External locations to create. Each location gets managed AQS file events enabled."

  validation {
    condition     = length(var.external_locations) > 0
    error_message = "At least one external location is required."
  }
}

variable "create_storage_credential" {
  type        = bool
  description = "When true, create a storage credential backed by the access connector. When false, use existing_credential_name."
  default     = true
}

variable "existing_credential_name" {
  type        = string
  description = "Name of an existing storage credential to reuse when create_storage_credential is false"
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

variable "assign_azure_rbac" {
  type        = bool
  description = "Assign the documented Azure RBAC roles required for data access and automatic managed file events"
  default     = true
}

variable "force_destroy" {
  type        = bool
  description = "Force destroy UC objects even if dependents exist"
  default     = true
}

variable "credential_grants" {
  type = list(object({
    principal  = string
    privileges = list(string)
  }))
  description = "UC grants on the storage credential. Defaults to empty (owner-only)."
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
