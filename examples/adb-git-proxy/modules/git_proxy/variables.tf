variable "spark_version" {
  type = string
}

variable "node_type_id" {
  type = string
}

variable "autotermination_minutes" {
  type    = number
  default = 0
}

variable "cluster_name" {
  type    = string
  default = "workspace-git-proxy-cluster"
}

variable "proxy_initscript_path" {
  type = string
}
