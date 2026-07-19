variable "databricks_host" {
  type        = string
  description = "Workspace URL, e.g. https://adb-xxxx.azuredatabricks.net"
}

variable "name_prefix" {
  type        = string
  description = "Prefix for UC object names"
  default     = "file-events-demo"
}

variable "access_connector_id" {
  type        = string
  description = "Azure resource ID of the Access Connector for Azure Databricks"
}

variable "storage_account_id" {
  type        = string
  description = "Azure resource ID of the ADLS Gen2 storage account"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group containing the storage account"
}

variable "external_location_name" {
  type        = string
  description = "Name of the Unity Catalog external location"
  default     = "file-events-landing"
}

variable "external_location_url" {
  type        = string
  description = "abfss:// URL for the external location path"
}

variable "grant_principal" {
  type        = string
  description = "UC group or user to grant on the credential and external location. Leave empty to skip grants."
  default     = ""
}
