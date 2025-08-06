variable "databricks_account_client_id" {
  type        = string
  description = "Application ID of account-level service principal"
}

variable "databricks_account_client_secret" {
  type        = string
  description = "Client secret of account-level service principal"
}

variable "databricks_account_id" {
  type        = string
  description = "Databricks Account ID"
}

variable "region" {
  type        = string
  description = "AWS region to deploy to"
}

#cmk
variable "cmk_admin" {
  type        = string
  description = "ARN of the user who will be the admin for CMK keys"
}

variable "tags" {
  type        = map(string)
  description = "Optional tags to add to created resources"
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

variable "workspace_vpce_service" {
  type        = string
  description = "Workspace VPC endpoint service name"
}

variable "relay_vpce_service" {
  type        = string
  description = "Relay VPC endpoint service name"
}

variable "workspace_1_config" {
  type = object({
    private_subnet_pair = object({
      subnet1_cidr = string
      subnet2_cidr = string
    })
    workspace_name   = string
    prefix           = string
    region           = string
    root_bucket_name = string
    block_list       = list(string)
    allow_list       = list(string)
    tags             = map(string)
  })
  description = "Configuration for workspace 1"
}

variable "workspace_2_config" {
  type = object({
    private_subnet_pair = object({
      subnet1_cidr = string
      subnet2_cidr = string
    })
    workspace_name   = string
    prefix           = string
    region           = string
    root_bucket_name = string
    block_list       = list(string)
    allow_list       = list(string)
    tags             = map(string)
  })
  description = "Configuration for workspace 2"
}
