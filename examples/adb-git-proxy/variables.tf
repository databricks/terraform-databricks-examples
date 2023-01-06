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
  type    = string
  default = "Standard_F4s_v2" // choose cheapest instance
}

variable "workspace_prefix" {
  type    = string
  default = "adb"
}

variable "proxy_cluster_name" {
  type    = string
  default = "git-proxy" // if you need to change this name, scripts folder content must be changed too as cluster name was hard coded
}

variable "proxy_auto_termination_minute" {
  type    = number
  default = 0
}
