variable "databricks_account_id" {
  type        = string
  description = "Databricks Account ID"
}

variable "google_region" {
  type        = string
  description = "Google Cloud region where the resources will be created"
}

variable "workspace_google_project" {
  type        = string
  description = "Google Cloud project ID related to Databricks workspace"
}

variable "spoke_vpc_google_project" {
  type        = string
  description = "Google Cloud project ID related to Spoke VPC"
}

variable "hub_vpc_google_project" {
  type        = string
  description = "Google Cloud project ID related to Hub VPC"
}

variable "is_spoke_vpc_shared" {
  type        = bool
  description = "Whether the Spoke VPC is a Shared or a dedicated VPC"
}

variable "prefix" {
  type        = string
  description = "Prefix to use in generated resources name"
}

# For the value of the regional Hive Metastore IP, refer to the Databricks documentation
# Here - https://docs.gcp.databricks.com/en/resources/ip-domain-region.html#addresses-for-default-metastore
variable "hive_metastore_ip" {
  type        = string
  description = "Value of regional default Hive Metastore IP"
}

variable "hub_vpc_cidr" {
  type        = string
  description = "CIDR for Hub VPC"
}

variable "spoke_vpc_cidr" {
  type        = string
  description = "CIDR for Spoke VPC"
}

variable "psc_subnet_cidr" {
  type        = string
  description = "CIDR for Spoke VPC"
}

variable "tags" {
  type        = map(string)
  description = "Map of tags to add to all resources"

  default = {}
}

