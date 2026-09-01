variable "azure_subscription_id" {
  type        = string
  description = "Azure subscription ID to deploy into."
}

variable "azure_region" {
  type        = string
  description = "Azure region short name (e.g. australiaeast). Must match your workspace region."
}

variable "rg_name" {
  type        = string
  description = "Name of the resource group to create for the private endpoint and DNS zone."
  default     = "rg-service-direct-pe"
}

variable "databricks_host" {
  type        = string
  description = "Databricks account console host."
  default     = "https://accounts.azuredatabricks.net"
}

variable "databricks_account_id" {
  type        = string
  description = "Databricks account ID (UUID)."
}

variable "private_endpoint_subnet_id" {
  type        = string
  description = "Resource ID of an existing subnet to host the private endpoint (PE network policies disabled)."
}

variable "databricks_pls_resource_id" {
  type        = string
  description = "Databricks per-region PLS resource ID for performance-intensive services (from the MS Learn region table)."
}

variable "create_private_dns_zone" {
  type        = bool
  description = "Create privatelink.azuredatabricks.net here, or reuse an existing zone."
  default     = true
}

variable "vnet_ids_to_link" {
  type        = list(string)
  description = "VNet IDs to link to the DNS zone (used only when create_private_dns_zone = true)."
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to created resources."
  default     = {}
}
