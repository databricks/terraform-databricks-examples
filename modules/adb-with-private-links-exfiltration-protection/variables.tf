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

variable "existing_resource_group_name" {
  type        = string
  description = "(Required) The name of the Resource Group to create"
  validation {
    condition     = var.create_resource_group == true || length(var.existing_resource_group_name) > 0
    error_message = "The resource_group_name variable cannot be empty if create_resource_group is set to false"
  }
}

variable "create_resource_group" {
  type        = bool
  description = "(Optional) Creates resource group if set to true (default)"
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

variable "test_vm_password" {
  type        = string
  default     = "TesTed567!!!"
  description = "Password for Test VM"
}

variable "private_subnet_endpoints" {
  description = "The list of Service endpoints to associate with the private subnet."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "map of tags to add to all resources"
  type        = map(any)
  default     = {}
}
