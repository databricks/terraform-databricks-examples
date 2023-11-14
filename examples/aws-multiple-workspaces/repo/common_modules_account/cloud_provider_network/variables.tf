variable "vpc_cidr_range" {
  type        = string
}

variable "availability_zones" {
  type        = list(string)
}

variable "resource_prefix" {
  type        = string
}

variable "public_subnets_cidr" {
  type        = list(string)
}

variable "private_subnets_cidr" {
  type        = list(string)
}

variable "sg_ingress_protocol" {
  type        = list(any)
}

variable "sg_egress_ports" {
  type        = list(any)
}

variable "sg_egress_protocol" {
  type        = list(any)
}

