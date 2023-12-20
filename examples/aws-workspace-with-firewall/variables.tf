variable "databricks_account_username" {}
variable "databricks_account_password" {}

variable "databricks_account_id" {
  type        = string
  description = "Databricks Account ID"
}

variable "tags" {
  default     = {}
  type        = map(string)
  description = "Optional tags to add to created resources"
}

variable "cidr_block" {
  description = "IP range for AWS VPC"
  type        = string
  default     = "10.4.0.0/16"
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
  default     = "london.cloud.databricks.com"
  description = "Hostname of Databricks web application"
  type        = string
}

variable "db_tunnel" {
  default     = "tunnel.eu-west-2.cloud.databricks.com"
  description = "Hostname of Databricks SCC Relay"
  type        = string
}

variable "db_rds" {
  default     = "mdio2468d9025m.c6fvhwk6cqca.eu-west-2.rds.amazonaws.com"
  description = "Hostname of AWS RDS instance for built-in Hive Metastore"
  type        = string
}

variable "db_control_plane" {
  default     = "18.134.65.240/28"
  description = "IP Range for AWS Databricks control plane"
  type        = string
}

variable "prefix" {
  default     = "demo"
  type        = string
  description = "Prefix for use in the generated names"
}
