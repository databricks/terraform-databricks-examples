variable "cidr_transit" {
  type        = string
  description = "(Required) The CIDR for the Azure transit VNet"
}

variable "cidr_dp" {
  type        = string
  description = "(Required) The CIDR for the Azure Data Plane VNet"
}

variable "location" {
  type        = string
  description = "(Required) The location for the resources in this module"
}

variable "public_network_access_enabled" {
  type        = bool
  description = "(Optional, default: false) If access from the public networks should be enabled"
  default     = false
}
