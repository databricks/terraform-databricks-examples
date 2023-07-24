variable "hubcidr" {
  type        = string
  default     = "10.178.0.0/20"
  description = "CIDR for Hub VNet"
}

variable "spokecidr" {
  type        = string
  default     = "10.179.0.0/20"
  description = "CIDR for Spoke VNet"
}

variable "rglocation" {
  type        = string
  default     = "southeastasia"
  description = "Location of resource group to create"
}

variable "metastoreip" {
  type        = string
  description = "IP Address of built-in Hive Metastore in the target region"
}

variable "dbfs_prefix" {
  type        = string
  default     = "dbfs"
  description = "Prefix for DBFS storage account name"
}

variable "workspace_prefix" {
  type        = string
  default     = "adb"
  description = "Prefix to use for Workspace name"
}

variable "firewallfqdn" {
  type        = list(any)
  description = "Additional list of fully qualified domain names to add to firewall rules"
}
