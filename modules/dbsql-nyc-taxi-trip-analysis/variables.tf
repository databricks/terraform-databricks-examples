variable "name_prefix" {
  type        = string
  description = "Prefix for the names of this module's dashboard and queries."
}

variable "data_source_id" {
  type        = string
  description = "Date source ID of the SQL warehouse to run queries against."
}
