variable "spokecidr" {
  type = string
}

variable "no_public_ip" {
  type = bool
}

variable "rglocation" {
  type = string
}

variable "dbfs_prefix" {
  type = string
}

variable "workspace_prefix" {
  type = string
}

variable "cidr" {
  type    = string
  default = "10.179.0.0/20"
}
