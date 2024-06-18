variable "databricks_account_username" {
  type = string
}

variable "databricks_account_password" {
  type = string
}

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
  type        = string
  default     = "eu-central-1"
  description = "AWS region to deploy to"
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

variable "enable_private_link" {
  type    = bool
  default = false
}

variable "prefix" {
  default     = "demo"
  type        = string
  description = "Prefix for use in the generated names"
}
