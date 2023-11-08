variable "databricks_account_id" {
  type        = string
  description = "Databricks Account ID"
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

variable "whitelisted_urls" {
  default     = [".pypi.org", ".pythonhosted.org", ".cran.r-project.org"]
  description = "List of the domains to allow traffic to"
  type        = list(string)
}

variable "db_web_app" {
  default     = "frankfurt.cloud.databricks.com"
  description = "Hostname of Databricks web application"
  type        = string
}

variable "db_tunnel" {
  default     = "tunnel.eu-central-1.cloud.databricks.com"
  description = "Hostname of Databricks SCC Relay"
  type        = string
}

variable "db_rds" {
  default     = "mdv2llxgl8lou0.ceptxxgorjrc.eu-central-1.rds.amazonaws.com"
  description = "Hostname of AWS RDS instance for built-in Hive Metastore"
  type        = string
}

variable "db_control_plane" {
  default     = "18.159.44.32/28"
  description = "IP Range for AWS Databricks control plane"
  type        = string
}

variable "prefix" {
  default     = "demo"
  type        = string
  description = "Prefix for use in the generated names"
}
