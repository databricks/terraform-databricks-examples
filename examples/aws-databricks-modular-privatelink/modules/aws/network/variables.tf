variable "resource_prefix" {
  type        = string
  description = "Prefix for resource names"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for VPC"
}

variable "public_subnets_cidr" {
  type        = list(string)
  description = "CIDR blocks for public subnets"
}

variable "privatelink_subnets_cidr" {
  type        = list(string)
  description = "CIDR blocks for privatelink subnets"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
}