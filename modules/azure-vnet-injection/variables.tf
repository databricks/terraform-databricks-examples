variable "prefix" {
  description = "Prefix for naming convention"
}

variable "location" {
  description = "Azure location"
}

variable "tags" {
  default     = {}
  description = "Different required tags"
}

variable "cidr_block" {
  description = "CIDR block for the custom Vnet"
}
