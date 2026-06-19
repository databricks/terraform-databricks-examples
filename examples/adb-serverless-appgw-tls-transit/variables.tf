variable "azure_subscription_id" {
  type        = string
  description = "Azure subscription ID to deploy into."
}

variable "azure_region" {
  type        = string
  description = "Azure region short name (e.g. australiaeast). Must match your workspace/NCC region."
}

variable "rg_name" {
  type        = string
  description = "Name of the resource group to create for the transit."
  default     = "rg-appgw-tls-transit"
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
  description = "Databricks workspace ID to bind the NCC to."
}

variable "backend_addresses" {
  type        = list(string)
  description = "IPs (or FQDNs) of the target TLS service, reachable from the transit VNet."
}

variable "serverless_domain_names" {
  type        = list(string)
  description = "FQDNs serverless clients dial (e.g. Kafka bootstrap + wildcard). Max 10."
}

variable "listener_port" {
  type        = number
  description = "TCP/TLS port (e.g. 9092/9094 for Kafka)."
  default     = 9092
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to created resources."
  default     = {}
}
