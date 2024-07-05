// provide existing vpc id for resources to deploy into
variable "existing_vpc_id" {
  type = string
}

variable "databricks_account_client_id" {
  type        = string
  description = "Application ID of account-level service principal"
}

variable "databricks_account_client_secret" {
  type        = string
  description = "Client secret of account-level service principal"
}

variable "databricks_account_id" {
  type = string
}

variable "region" {
  type    = string
  default = "ap-southeast-1"
}

variable "prefix" {
  type = string
}

variable "aws_nat_gateway_id" {
  type = string
}

//contains only 2 subnets cidr blocks
variable "private_subnet_pair" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}
