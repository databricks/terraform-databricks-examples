variable "databricks_account_username" {}
variable "databricks_account_password" {}
variable "databricks_account_id" {}

variable "tags" {
  default = {}
}

variable "spoke_cidr_block" {
  default = "10.173.0.0/16"
}
variable "hub_cidr_block" {
  default = "10.10.0.0/16"
}
variable "region" {
  default = "eu-central-1"
}

variable "whitelisted_urls" {
  default = [".pypi.org", ".pythonhosted.org", ".cran.r-project.org"]
}

variable "prefix" {
  default = "demo"
}