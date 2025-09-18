variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID to deploy the workspace into"
}

variable "existing_resource_group_name" {
  type        = string
  description = "Specify the name of an existing Resource Group only if you do not want Terraform to create a new one"
  validation {
    condition     = var.create_resource_group == true || length(var.existing_resource_group_name) > 0
    error_message = "The existing_resource_group_name must be provided when create_resource_group is set to false"
  }
  default = ""
}

variable "create_resource_group" {
  type        = bool
  description = "Set to true to create a new Azure Resource Group. Set to false to use an existing Resource Group specified in existing_resource_group_name"
  default     = true
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



