variable "no_public_ip" {
  type    = bool
  default = true
}

variable "rglocation" {
  type    = string
  default = "southeastasia"
}

variable "dbfs_prefix" {
  type    = string
  default = "dbfs"
}

variable "node_type" {
  type = string
  default = "Standard_E8ds_v4"
}

variable "workspace_prefix" {
  type    = string
  default = "adb"
}

variable "global_auto_termination_minute" {
  type    = number
  default = 30
}
