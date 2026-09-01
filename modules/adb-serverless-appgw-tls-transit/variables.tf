variable "azure_subscription_id" {
  type        = string
  description = "Azure subscription ID to deploy into."

  validation {
    condition     = can(regex("^[0-9a-fA-F-]{36}$", var.azure_subscription_id))
    error_message = "azure_subscription_id must be a UUID."
  }
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

  validation {
    condition     = var.appgw_capacity >= 1 && var.appgw_capacity <= 10 && floor(var.appgw_capacity) == var.appgw_capacity
    error_message = "appgw_capacity must be a whole number between 1 and 10."
  }
}

variable "databricks_host" {
  type        = string
  description = "Databricks account console host."
  default     = "https://accounts.azuredatabricks.net"

  validation {
    condition     = can(regex("^https://[a-zA-Z0-9.-]+/?$", var.databricks_host))
    error_message = "databricks_host must be an HTTPS URL with a hostname."
  }
}

variable "databricks_account_id" {
  type        = string
  description = "Databricks account ID (UUID)."

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.databricks_account_id))
    error_message = "databricks_account_id must be a UUID."
  }
}

variable "databricks_workspace_id" {
  type        = string
  description = "Databricks workspace ID to bind to the NCC."

  validation {
    condition     = can(tonumber(var.databricks_workspace_id)) && tonumber(var.databricks_workspace_id) > 0
    error_message = "databricks_workspace_id must be a positive numeric workspace ID."
  }
}

variable "backend_addresses" {
  type        = list(string)
  description = "IPv4 addresses of TLS backends reachable from the transit VNet."
  default     = []

  validation {
    condition = alltrue([
      for address in var.backend_addresses : can(cidrhost("${address}/32", 0))
    ])
    error_message = "backend_addresses must contain IPv4 addresses."
  }
}

variable "backend_fqdns" {
  type        = list(string)
  description = "FQDNs of TLS backends reachable from the transit VNet."
  default     = []

  validation {
    condition     = alltrue([for fqdn in var.backend_fqdns : length(trimspace(fqdn)) > 0])
    error_message = "backend_fqdns must not contain empty values."
  }
}

variable "serverless_domain_names" {
  type        = list(string)
  description = "FQDNs that serverless clients dial. The NCC rule supports at most 10 names."

  validation {
    condition = (
      length(var.serverless_domain_names) > 0 &&
      length(var.serverless_domain_names) <= 10 &&
      length(distinct(var.serverless_domain_names)) == length(var.serverless_domain_names) &&
      alltrue([
        for domain in var.serverless_domain_names : domain == trimspace(domain) && can(regex("^(\\*\\.)?([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\\.)+[a-zA-Z0-9]{2,63}$", domain))
      ])
    )
    error_message = "Provide 1 to 10 unique FQDNs; a leading wildcard such as *.example.com is allowed."
  }
}

variable "listener_port" {
  type        = number
  description = "TCP/TLS port exposed by the Application Gateway."
  default     = 9092

  validation {
    condition     = var.listener_port >= 1 && var.listener_port <= 65535 && floor(var.listener_port) == var.listener_port
    error_message = "listener_port must be a whole number between 1 and 65535."
  }
}

variable "backend_port" {
  type        = number
  description = "TCP/TLS port used by the backend. Defaults to listener_port."
  default     = null

  validation {
    condition     = var.backend_port == null ? true : (var.backend_port >= 1 && var.backend_port <= 65535 && floor(var.backend_port) == var.backend_port)
    error_message = "backend_port must be null or a whole number between 1 and 65535."
  }
}

variable "vnet_address_space" {
  type        = list(string)
  description = "Address space for the transit VNet."
  default     = ["10.230.0.0/16"]
}

variable "appgw_subnet_prefix" {
  type        = string
  description = "Address prefix for the Application Gateway subnet. The subnet must provide at least ten usable host addresses."
  default     = "10.230.1.0/24"

  validation {
    condition     = can(cidrhost(var.appgw_subnet_prefix, 10))
    error_message = "appgw_subnet_prefix must be a valid IPv4 subnet with at least ten usable host addresses."
  }
}

variable "appgw_pls_subnet_prefix" {
  type        = string
  description = "Address prefix for the dedicated Application Gateway Private Link subnet."
  default     = "10.230.2.0/24"

  validation {
    condition     = can(cidrhost(var.appgw_pls_subnet_prefix, 1))
    error_message = "appgw_pls_subnet_prefix must be a valid IPv4 subnet."
  }
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
