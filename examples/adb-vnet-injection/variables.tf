variable "no_public_ip" {
  type        = bool
  default     = true
  description = "If Secure Cluster Connectivity (No Public IP) should be enabled. Default: true"
}

variable "rglocation" {
  type        = string
  default     = "southeastasia"
  description = "Location of resource group to create"
}

variable "dbfs_prefix" {
  type        = string
  default     = "dbfs"
  description = "Name prefix for DBFS Root Storage account"
}

variable "node_type" {
  type        = string
  default     = "Standard_DS3_v2"
  description = "Node type for created cluster"
}

variable "workspace_prefix" {
  type        = string
  default     = "adb"
  description = "Name prefix for Azure Databricks workspace"
}

variable "global_auto_termination_minute" {
  type        = number
  default     = 30
  description = "Auto-termination time for created cluster"
}

variable "cidr" {
  type        = string
  default     = "10.179.0.0/20"
  description = "Network range for created VNet"
}

variable "tags" {
  type        = map(string)
  description = "Optional tags to add to resources"
  default     = {}
}


