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

variable "prefix" {
  type    = string
  default = "demo"
}

variable "enable_private_link" {
  type    = bool
  default = false
}