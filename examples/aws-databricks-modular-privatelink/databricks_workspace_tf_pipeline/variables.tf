variable "databricks_account_id" {
  type = string
}

variable "client_id" {
  type = string
}

variable "client_secret" {
  type = string
}

variable "databricks_host" {
  type = string
}

variable "region" {
  type    = string
  default = "ap-southeast-1"
}

variable "databricks_users" {
  type        = list(string)
  description = "List of Databricks usernames who need dedicated single node clusters"
}
