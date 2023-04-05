variable "databricks_account_id" {
  type = string
}

variable "credentials_id" {
  type = string
}

variable "prefix" {
  type = string // should be a randomized string  
}

variable "region" {
  type = string
}

variable "workspace_name" {
  type = string
}

// for network config
variable "existing_vpc_id" {
  type = string
}

variable "nat_gateways_id" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
}

variable "private_subnet_pair" {
  type = list(string)
}
// for cmk config
variable "managed_services_cmk" {
}

variable "workspace_storage_cmk" {
}

variable "root_bucket_name" {
  type = string
}

variable "relay_vpce_id" {
  type = list(string)
}

variable "rest_vpce_id" {
  type = list(string)
}

variable "tags" {
  type = map(string)
}
