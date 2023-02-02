variable "databricks_account_username" {
  type = string
}

variable "databricks_account_password" {
  type = string
}

variable "databricks_account_id" {
  type = string
}

variable "region" {
  type    = string
  default = "ap-southeast-1"
}

variable "tags" {
  default = {}
}

variable "vpc_cidr" {
  default = "10.109.0.0/17"
}

variable "public_subnets_cidr" {
  type    = list(string)
  default = ["10.109.2.0/23"]
}

variable "private_subnet_pair" {
  type    = list(string)
  default = ["10.109.4.0/23", "10.109.6.0/23"]
}
