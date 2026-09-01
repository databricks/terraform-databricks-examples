variable "azure_subscription_id" {
  type        = string
  description = "Azure subscription ID to deploy the private endpoint and DNS into."
}

variable "azure_region" {
  type        = string
  description = "Azure region short name (e.g. australiaeast, westus2). Used for the resource group/PE location, the <region>.service-direct DNS A record, and the databricks_endpoint region. Must match your workspace region."
}

variable "rg_name" {
  type        = string
  description = "Name of the resource group to create for the private endpoint (and the private DNS zone, when this module creates it)."
}

variable "databricks_host" {
  type        = string
  description = "Databricks account console host. databricks_endpoint requires an account-level provider."
  default     = "https://accounts.azuredatabricks.net"
}

variable "databricks_account_id" {
  type        = string
  description = "Databricks account ID (UUID)."
}

variable "private_endpoint_subnet_id" {
  type        = string
  description = "Resource ID of an existing subnet to host the private endpoint. Private endpoint network policies must be disabled (the Azure default); use a subnet separate from the workspace's own subnets if you reuse the workspace VNet."
}

variable "databricks_pls_resource_id" {
  type        = string
  description = "Databricks-published Private Link Service resource ID for performance-intensive services in your region. These are per-region and managed by Databricks — pull the current value from the Microsoft Learn region table (Service-direct resource IDs): https://learn.microsoft.com/en-us/azure/databricks/resources/ip-domain-region#service-direct-resource-ids"
}

variable "endpoint_display_name" {
  type        = string
  description = "Display name for the databricks_endpoint registration. Must be RFC-1034 compliant (letters, numbers, hyphens; starts with a letter; <= 63 chars)."
  default     = "service-direct-pe"

  validation {
    condition     = can(regex("^[a-zA-Z]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?$", var.endpoint_display_name))
    error_message = "endpoint_display_name must be RFC-1034 compliant: start with a letter, contain only letters/numbers/hyphens, end with a letter or number, max 63 chars."
  }
}

variable "private_endpoint_name" {
  type        = string
  description = "Name of the Azure private endpoint."
  default     = "pe-service-direct"
}

variable "subresource_name" {
  type        = string
  description = "Target sub-resource (group ID) for the private endpoint connection. Per Microsoft Learn this is service_direct (underscore). Exposed only so it can be overridden if Databricks changes the published group ID during Public Preview."
  default     = "service_direct"
}

variable "request_message" {
  type        = string
  description = "Request message attached to the manual private-endpoint connection."
  default     = "Databricks service-direct private endpoint (performance-intensive services)"
}

variable "create_private_dns_zone" {
  type        = bool
  description = "Whether to create the privatelink.azuredatabricks.net private DNS zone. Set false to reuse an existing zone (common when the workspace already uses inbound Private Link); the A record is added to the existing zone."
  default     = true
}

variable "private_dns_zone_name" {
  type        = string
  description = "Name of the private DNS zone. service-direct shares the workspace front-end Private Link zone."
  default     = "privatelink.azuredatabricks.net"
}

variable "vnet_ids_to_link" {
  type        = list(string)
  description = "VNet IDs to link to the private DNS zone (only used when create_private_dns_zone = true). When reusing an existing zone, manage links separately."
  default     = []
}

variable "dns_a_record_ttl" {
  type        = number
  description = "TTL (seconds) for the <region>.service-direct A record."
  default     = 3600
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to all created resources."
  default     = {}
}
