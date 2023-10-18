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
  default = [
    ".pypi.org", ".pythonhosted.org",   # python packages
    ".cran.r-project.org",              # R packages
    ".maven.apache.org", ".maven.org",  # maven artifacts
    ".storage-download.googleapis.com", # maven mirror
    ".spark-packages.org",              # spark packages
  ]
}

variable "prefix" {
  default = "demo"
}

variable "enable_private_link" {
  default = false
}