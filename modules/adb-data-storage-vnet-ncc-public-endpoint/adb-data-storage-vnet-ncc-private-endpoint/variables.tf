# Variable for the Azure region where resources will be deployed
variable "azure_region" {
  type    = string
  default = ""
}

# Variable for the name of the resource group to create
variable "rg_name" {
  type    = string
  default = ""
}

# Variable for the prefix used in naming resources
variable "name_prefix" {
  type    = string
  default = ""
}

# Variable for the name of the storage account for DBFS
variable "dbfs_storage_account" {
  type    = string
  default = ""
}

# Variable for the Azure subscription ID used for authentication
variable "azure_subscription_id" {
  type  = string
  default = ""
}

# Variable for the CIDR block range of the virtual network
variable "cidr_block" {
  description = "VPC CIDR block range"
  type        = string
  default     = "10.20.0.0/23"
}

# Variable for the CIDR block of the private subnet for cluster containers
variable "private_subnets_cidr" {
  type = string
  default = "10.20.0.0/25"
}

# Variable for the CIDR block of the public subnet for cluster hosts
variable "public_subnets_cidr" {
  type = string
  default = "10.20.0.128/25"
}

// Variable for the CIDR block of the Private Link subnets
variable "pl_subnets_cidr" { 
  type = string
  default = "10.20.1.0/27"
}

# Variable for service endpoints to enable on subnets
variable "subnet_service_endpoints" {
  type = list(string)
  default = []
}

# Variable to control whether network security group rules are required
variable "network_security_group_rules_required" {
  type = string
  default = "AllRules"
  # Options:
  #   - "AllRules"
  #   - "NoAzureServiceRules"
  #   - "NoAzureDatabricksRules" (use with private link)
}

# Variable to control whether public access to the default storage account is disallowed
variable "default_storage_firewall_enabled" {
  description = "Disallow public access to default storage account"
  type = bool
  default = false
}

# Variable to control whether public access to the frontend workspace web UI is allowed
variable "public_network_access_enabled" {
  description = "Allow public access to frontend workspace web UI"
  type = bool
  default = true
}

# Variable for the Databricks account URL
variable "databricks_host" {
  description = "Databricks Account URL"
  type        = string
  default     = ""
}

# Variable for the Databricks account ID
variable "databricks_account_id" {
  description = "Your Databricks Account ID"
  type        = string
  default = ""
}

# Variable for the name of the Databricks Unity Catalog metastore
variable "databricks_metastore" {
  description = "Databricks UC Metastore"
  type        = string
  default     = ""
}

# Variable for the resource group name of the ADLS storage account
variable "data_storage_account_rg" {
  description = "ADLS Storage account resource group"
  type        = string
  default     = ""
}

# Variable for the name of the ADLS storage account
variable "data_storage_account" {
  description = "ADLS Storage account Name"
  type        = string
  default     = ""
}

# Variable for the list of allowed IP addresses for the storage account
variable "storage_account_allowed_ips" {
  type = list(string)
  default = []
}

# Variable for the name of the catalog in the metastore
variable "databricks_calalog" {
  description = "Name of catalog in metastore"
  type        = string
  default     = ""
}

# Variable for the name of the principal to grant access to the catalog
variable "principal_name" {
  description = "Name of principal to grant access to catalog"
  type        = string
  default     = ""
}

# Variable for the list of privileges to grant to the principal on the catalog
variable "catalog_privileges" {
  description = "List of Privileges to catalog (grant to principal_name)"
  type        = list(string)
  default     = ["BROWSE"]
}

# Variable for tags to apply to resources for organization and billing
variable "tags" {
  default = ""
}
