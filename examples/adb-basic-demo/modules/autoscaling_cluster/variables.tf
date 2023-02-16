variable "spark_version" {
  type = string
}

variable "node_type_id" {
  type = string
}

variable "autotermination_minutes" {
  type    = number
  default = 60
}
