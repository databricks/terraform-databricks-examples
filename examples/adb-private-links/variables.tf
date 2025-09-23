variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID to deploy the workspace into"
}

variable "hubcidr" {
  type    = string
  default = "10.178.0.0/20"
}

variable "spokecidr" {
  type    = string
  default = "10.179.0.0/20"
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
  type    = string
  default = "southeastasia"
}

variable "metastoreip" {
  type = string
}
variable "dbfs_prefix" {
  type    = string
  default = "dbfs"
}

variable "workspace_prefix" {
  type    = string
  default = "adb"
}

variable "firewallfqdn" {
  type = list(any)
}
