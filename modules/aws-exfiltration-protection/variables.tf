variable "databricks_account_id" {
  type        = string
  description = "Databricks Account ID"
}

variable "whitelisted_urls" {
  type = list(string)
  default = [
    ".pypi.org", ".pythonhosted.org",   # python packages
    ".cran.r-project.org",              # R packages
    ".maven.org",                       # maven artifacts
    ".storage-download.googleapis.com", # maven mirror
    ".spark-packages.org",              # spark packages
  ]
  description = "List of the domains to allow traffic to"
}

variable "db_web_app" {
  type        = string
  default     = null # will use predefined for the region if not provided
  description = "Webapp address that corresponds to the cloud region"
}

variable "db_tunnel" {
  type        = string
  default     = null # will use predefined for the region if not provided
  description = "SCC relay address that corresponds to the cloud region"
}

variable "db_rds" {
  type        = string
  default     = null # will use predefined for the region if not provided
  description = "RDS address for legacy Hive metastore that corresponds to the cloud region"
}

variable "db_control_plane" {
  type        = string
  default     = null # will use predefined for the region if not provided
  description = "Control plane infrastructure address that corresponds to the cloud region"
}

variable "enable_private_link" {
  type        = bool
  default     = true
  description = "Property to enable / disable Private Link"
}

variable "vpc_endpoint_backend_rest" {
  type        = string
  default     = null # will use predefined for the region if not provided
  description = "VPC endpoint for workspace including REST API"
}

variable "vpc_endpoint_backend_relay" {
  type        = string
  default     = null # will use predefined for the region if not provided
  description = "VPC endpoint for relay service (secure cluster connectivity)"
}

variable "tags" {
  default     = {}
  type        = map(string)
  description = "Optional tags to add to created resources"
}

variable "spoke_cidr_block" {
  default     = "10.173.0.0/16"
  description = "IP range for spoke AWS VPC"
  type        = string
}

variable "hub_cidr_block" {
  default     = "10.10.0.0/16"
  description = "IP range for hub AWS VPC"
  type        = string
}

variable "region" {
  default     = "eu-west-2"
  type        = string
  description = "AWS region to deploy to"
}

variable "prefix" {
  default     = "demo"
  type        = string
  description = "Prefix for use in the generated names"
}
