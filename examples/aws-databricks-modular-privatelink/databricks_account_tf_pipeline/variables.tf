variable "databricks_account_id" {
  type = string
}

variable "aws_account_id" {
  type = string
}

variable "client_id" {
  type = string
}

variable "client_secret" {
  type = string
}

variable "region" {
  type    = string
  default = "ap-southeast-1"
}

variable "resource_prefix" {
  type    = string
  default = "hao-tf"
}

variable "vpc_name" {
  type    = string
  default = "hao-demo-vpc1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "workspace_number" {
  type        = number
  default     = 2
  description = "determins how many workspaces security groups will be created from aws_network module, each workspace will have one security group"
}

variable "number_of_azs" {
  type        = number
  description = "Used in vpc module, how many AZs to create subnets in"
}

variable "deploy_metastore" {
  type        = string
  default     = "false"
  description = "deploy metastore"
}

variable "existing_metastore_id" {
  type        = string
  description = "metastore id if it's already created"
}

variable "metastore_admin_group_name" {
  type        = string
  description = "metastore admin group name"
}

variable "deploy_log_delivery" {
  type        = string
  description = "deploy log delivery for the environment, using dedicated s3 bucket and role"
  default     = "false"
}

variable "private_subnets" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24"]
}

variable "private_subnet_names" {
  type    = list(string)
  default = ["private-subnet-1", "private-subnet-2", "private-subnet-3", "private-subnet-4"]
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "public_subnet_names" {
  type    = list(string)
  default = ["public-subnet-1", "public-subnet-2"]
}

variable "intra_subnets" {
  type    = list(string)
  default = ["10.0.103.0/27", "10.0.104.0/27"]
}

variable "intra_subnet_names" {
  type    = list(string)
  default = ["privatelink-subnet-1", "privatelink-subnet-2"]
}

variable "sg_egress_ports" {
  description = "List of egress ports for security groups."
  type        = list(string)
  default     = [443, 2443, 3306, 6666, 8443, 8444, 8445, 8446, 8447, 8448, 8449, 8450, 8451]
}

variable "scc_relay" {
  type = string
}

variable "workspace" {
  type = string
}

variable "tags" {
  default = {}
}
