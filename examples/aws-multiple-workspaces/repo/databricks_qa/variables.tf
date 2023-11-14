variable "availability_zones" {
  type        = list(string)
}

variable "aws_account_id" {
  type        = string
}

variable "client_id" {
  type        = string
}

variable "client_secret" {
  type        = string
}

variable "databricks_account_id" {
  type        = string
}

variable "dbfsname" {
  type        = string
}

variable "metastore_id" {
  type        = string
}

variable "private_subnets_cidr" {
  type        = list(string)
}

variable "public_subnets_cidr" {
  type        = list(string)
}

variable "region" {
  type        = string
}

variable "resource_prefix" {
  type        = string
}

variable "resource_owner" {
  type        = string
}

variable "sg_egress_ports" {
  type        = list(any)
}

variable "sg_egress_protocol" {
  type        = list(any)
}

variable "sg_ingress_protocol" {
  type        = list(any)
}

variable "team" {
  type        = string
}

variable "user_name" {
  type        = string
}

variable "vpc_cidr_range" {
  type        = string
}
