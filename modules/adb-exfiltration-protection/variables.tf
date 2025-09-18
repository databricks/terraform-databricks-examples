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

variable "existing_resource_group_name" {
  type        = string
  description = "Specify the name of an existing Resource Group only if you do not want Terraform to create a new one"
  validation {
    condition     = var.create_resource_group == true || length(var.existing_resource_group_name) > 0
    error_message = "The existing_resource_group_name must be provided when create_resource_group is set to false"
  }
}

variable "create_resource_group" {
  type        = bool
  description = "Set to true to create a new Azure Resource Group. Set to false to use an existing Resource Group specified in existing_resource_group_name"
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
  type        = list(string)
  description = "List of domains names to put into application rules for handling of HTTPS traffic (Databricks storage accounts, etc.)"
}

variable "tags" {
  description = "Additional tags to add to created resources"
  default     = {}
  type        = map(string)
}

variable "bypass_scc_relay" {
  description = "If we should bypass firewall for Secure Cluster Connectivity traffic or not"
  type        = bool
  default     = true
}
