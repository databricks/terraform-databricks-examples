variable "metastore_name" {
  type        = string
  description = "the name of the metastore"
}


variable "metastore_storage_name" {
  type        = string
  description = "the account storage where we create the metastore"
}

variable "access_connector_id" {
  type        = string
  description = "the id of the access connector"
}

variable "access_connector_name" {
  type        = string
  description = "the name of the access connector"
}

variable "metastore_id" {
  type        = string
  description = "the id of the metastore"
}

variable "workspace_id" {
  type        = string
  description = "the id of the workspace"
}

variable "metastore_admins" {
  type        = list(string)
  description = "list of principals: service principals or groups that have metastore admin privileges"
}