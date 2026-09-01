variable "azure_subscription_id" {
  type        = string
  description = "Azure subscription ID to deploy into."
}

variable "azure_region" {
  type        = string
  description = "Azure region short name. Must match the workspace and NCC region."
}

variable "rg_name" {
  type        = string
  description = "Resource group to create for the transit resources."
  default     = "rg-appgw-tls-transit"
}

variable "appgw_name" {
  type        = string
  description = "Application Gateway name."
  default     = "appgw-serverless-transit"
}

variable "appgw_capacity" {
  type        = number
  description = "Fixed Standard_v2 Application Gateway instance capacity."
  default     = 2
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

variable "databricks_workspace_id" {
  type        = string
  description = "Databricks workspace ID to bind to the NCC."
}

variable "backend_addresses" {
  type        = list(string)
  description = "IPv4 addresses of TLS backends reachable from the transit VNet."
  default     = []
}

variable "backend_fqdns" {
  type        = list(string)
  description = "FQDNs of TLS backends reachable from the transit VNet."
  default     = []
}

variable "serverless_domain_names" {
  type        = list(string)
  description = "FQDNs that serverless clients dial. The NCC rule supports at most 10 names."
}

variable "listener_port" {
  type        = number
  description = "TCP/TLS port exposed by the Application Gateway."
  default     = 9092
}

variable "backend_port" {
  type        = number
  description = "TCP/TLS port used by the backend. Defaults to listener_port."
  default     = null
}

variable "auto_approve_private_endpoint" {
  type        = bool
  description = "Attempt to approve the Databricks-created private endpoint with Azure CLI."
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to created resources."
  default     = {}
}
