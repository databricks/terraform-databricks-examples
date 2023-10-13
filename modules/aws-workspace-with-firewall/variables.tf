variable "databricks_account_id" {}

variable "tags" {
  default = {}
}

variable "cidr_block" {
  default = "10.4.0.0/16"
}

variable "region" {
  default = "eu-west-2"
}

resource "random_string" "naming" {
  special = false
  upper   = false
  length  = 6
}

variable "whitelisted_urls" {
  default = [".pypi.org", ".pythonhosted.org", ".cran.r-project.org"]
}

variable "db_web_app" {
  default = "london.cloud.databricks.com"
}

variable "db_tunnel" {
  default = "tunnel.eu-west-2.cloud.databricks.com"
}

variable "db_rds" {
  default = "mdio2468d9025m.c6fvhwk6cqca.eu-west-2.rds.amazonaws.com"
}

variable "db_control_plane" {
  default = "18.134.65.240/28"
}

variable "prefix" {
  default = "demo"
}