variable "databricks_account_username" {
  type = string
}

variable "databricks_account_password" {
  type = string
}

variable "databricks_account_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "spoke_cidr_block" {
  type    = string
  default = "10.173.0.0/16"
}

variable "hub_cidr_block" {
  type    = string
  default = "10.10.0.0/16"
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

resource "random_string" "naming" {
  special = false
  upper   = false
  length  = 6
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

variable "prefix" {
  type    = string
  default = "demo"
}