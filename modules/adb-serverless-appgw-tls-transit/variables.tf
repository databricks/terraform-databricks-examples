# =============================================================================
# Account / subscription
# =============================================================================

variable "azure_subscription_id" {
  type        = string
  description = "Azure subscription ID to deploy the transit into."
}

variable "azure_region" {
  type        = string
  description = "Azure region short name (e.g. australiaeast). Must match your Databricks workspace/NCC region."
}

variable "rg_name" {
  type        = string
  description = "Name of the resource group to create for the transit (VNet, App Gateway, public IP)."
}

variable "databricks_host" {
  type        = string
  description = "Databricks account console host. The NCC resources require an account-level provider."
  default     = "https://accounts.azuredatabricks.net"
}

variable "databricks_account_id" {
  type        = string
  description = "Databricks account ID (UUID)."
}

variable "databricks_workspace_id" {
  type        = string
  description = "Databricks workspace ID to bind the NCC to."
}

# =============================================================================
# Target service (generic — Kafka brokers or any TLS workload)
# =============================================================================

variable "backend_addresses" {
  type        = list(string)
  description = "Backend target addresses reachable from the App Gateway VNet — the IPs (or FQDNs) of the TLS service (e.g. Kafka brokers, an internal load balancer, or a private endpoint to a provider PLS). You are responsible for connectivity from the App Gateway VNet to these addresses (in-VNet, VNet peering, or a private endpoint)."

  validation {
    condition     = length(var.backend_addresses) > 0
    error_message = "Provide at least one backend address."
  }
}

variable "serverless_domain_names" {
  type        = list(string)
  description = "FQDNs that Databricks Serverless clients will dial (e.g. Kafka bootstrap + per-broker/wildcard FQDNs). NCC injects DNS so these resolve to the Databricks-managed private endpoint. Max 10 per rule."

  validation {
    condition     = length(var.serverless_domain_names) > 0 && length(var.serverless_domain_names) <= 10
    error_message = "Provide between 1 and 10 domain names (Azure NCC limit is 10 per rule)."
  }
}

variable "listener_port" {
  type        = number
  description = "TCP port the TLS service listens on and that clients connect to (e.g. 9092/9094 for Kafka)."
  default     = 9092
}

variable "backend_port" {
  type        = number
  description = "Backend port to forward to. Defaults to listener_port when null."
  default     = null
}

# =============================================================================
# Networking
# =============================================================================

variable "vnet_address_space" {
  type        = list(string)
  description = "Address space for the transit VNet."
  default     = ["10.230.0.0/16"]
}

variable "appgw_subnet_prefix" {
  type        = string
  description = "Address prefix for the Application Gateway subnet."
  default     = "10.230.1.0/24"
}

variable "appgw_pls_subnet_prefix" {
  type        = string
  description = "Address prefix for the Application Gateway Private Link subnet (hosts the PL config IP configuration)."
  default     = "10.230.2.0/24"
}

variable "appgw_frontend_private_ip" {
  type        = string
  description = "Static private IP for the App Gateway private frontend (must be inside appgw_subnet_prefix)."
  default     = "10.230.1.100"
}

# =============================================================================
# App Gateway
# =============================================================================

variable "appgw_name" {
  type        = string
  description = "Name of the Application Gateway."
  default     = "appgw-serverless-transit"
}

variable "appgw_capacity" {
  type        = number
  description = "Fixed instance capacity for the Application Gateway v2 (Standard_v2)."
  default     = 2
}

# =============================================================================
# NCC
# =============================================================================

variable "ncc_name" {
  type        = string
  description = "Name for the Network Connectivity Configuration."
  default     = "ncc-appgw-transit"
}

variable "auto_approve_private_endpoint" {
  type        = bool
  description = "Automatically approve the Databricks private endpoint connection on the App Gateway (via az CLI). Set false to approve manually in the Azure portal (NCC docs Step 4)."
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to created resources."
  default     = {}
}
