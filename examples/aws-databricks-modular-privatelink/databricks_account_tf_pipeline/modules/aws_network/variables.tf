variable "region" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "workspace_number" {
  type        = number
  description = "How many workspaces to create in this segment in the same VPC"
}

variable "number_of_azs" {
  type        = number
  description = "Used in vpc module, how many AZs to create subnets in"
}

variable "private_subnets" {
  type        = list(string)
  description = "Used in vpc module, list of private subnets to create, each workspace will have at least 2 subnets from different AZs"
}

variable "private_subnet_names" {
  type = list(string)
}

variable "public_subnets" {
  type = list(string)
}

variable "public_subnet_names" {
  type = list(string)
}

variable "intra_subnets" {
  type = list(string)
}

variable "intra_subnet_names" {
  type = list(string)
}

variable "resource_prefix" {
  type = string
}

variable "sg_egress_ports" {
  description = "List of egress ports for security groups."
  type        = list(string)
}

variable "scc_relay" {
  type = string
}

variable "workspace" {
  type = string
}
