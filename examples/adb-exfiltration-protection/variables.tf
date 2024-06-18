variable "hubcidr" {
  description = "IP range for creaiton of the Spoke VNet"
  type        = string
  default     = "10.178.0.0/20"
}

variable "spokecidr" {
  description = "IP range for creaiton of the Hub VNet"
  type        = string
  default     = "10.179.0.0/20"
}

variable "no_public_ip" {
  description = "If workspace should be created with No-Public-IP"
  type        = bool
  default     = true
}

variable "rglocation" {
  description = "Location of resource group"
  type        = string
}

variable "metastore" {
  description = "List of FQDNs for Azure Databricks Metastore databases"
  type        = list(string)
}

variable "scc_relay" {
  description = "List of FQDNs for Azure Databricks Secure Cluster Connectivity relay"
  type        = list(string)
}

variable "webapp_ips" {
  description = "List of IP ranges for Azure Databricks Webapp"
  type        = list(string)
}

variable "eventhubs" {
  description = "List of FQDNs for Azure Databricks EventHubs traffic"
  type        = list(string)
}

variable "dbfs_prefix" {
  description = "Prefix for DBFS storage account name"
  type        = string
  default     = "dbfs"
}

variable "workspace_prefix" {
  description = "Prefix for workspace name"
  type        = string
  default     = "adb"
}

variable "firewallfqdn" {
  type        = list(any)
  description = "List of domains names to put into application rules for handling of HTTPS traffic (Databricks storage accounts, etc.)"
}

variable "tags" {
  description = "Additional tags to add to created resources"
  default     = {}
  type        = map(string)
}
