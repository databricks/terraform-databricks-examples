variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID to deploy the workspace into"
}

variable "cidr_transit" {
  type        = string
  description = "(Required) The CIDR for the Azure transit VNet"
}

variable "cidr_dp" {
  type        = string
  description = "(Required) The CIDR for the Azure Data Plane VNet"
}

variable "existing_data_plane_resource_group_name" {
  type        = string
  description = "Specify the name of an existing Resource Group for Data plane resources only if you do not want Terraform to create a new one"
  validation {
    condition     = var.create_data_plane_resource_group == true || length(var.existing_data_plane_resource_group_name) > 0
    error_message = "The resource_group_name variable cannot be empty if create_resource_group is set to false"
  }
  default = ""
}

variable "create_data_plane_resource_group" {
  type        = bool
  description = "Set to true to create a new Azure Resource Group for data plane resources. Set to false to use an existing Resource Group specified in existing_data_plane_resource_group_name"
  default     = true
}

variable "existing_transit_resource_group_name" {
  type        = string
  description = "Specify the name of an existing Resource Group for transit VNet resources only if you do not want Terraform to create a new one"
  validation {
    condition     = var.create_transit_resource_group == true || length(var.existing_transit_resource_group_name) > 0
    error_message = "The resource_group_name variable cannot be empty if create_resource_group is set to false"
  }
  default = ""
}

variable "create_transit_resource_group" {
  type        = bool
  description = "Set to true to create a new Azure Resource Group for transit VNet resources. Set to false to use an existing Resource Group specified in existing_transit_resource_group_name"
  default     = true
}

variable "location" {
  type        = string
  description = "(Required) The location for the resources in this module"
}
