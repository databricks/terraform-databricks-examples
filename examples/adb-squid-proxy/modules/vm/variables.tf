variable "resource_group_name" {
  description = "Azure resource group name"
}

variable "vnetcidr" {
  type    = string
  default = "10.178.0.0/20"
}

variable "loc" {
  type    = string
  default = "southeastasia"
}