variable "access_connector_id" {
  type        = string
  description = "The id of the access connector that will be assumed by Unity Catalog to access data"
}

variable "metastore_name" {
  type        = string
  description = "the name of the metastore"
}


variable "metastore_storage_name" {
  type        = string
  description = "the account storage where we create the metastore"
}

variable "access_connector_name" {
  type        = string
  description = "the name of the access connector"
}

variable "metastore_id" {
  type        = string
  description = "Id of the metastore"
}

variable "workspace_id" {
  type        = string
  description = "Id of the workspace"
}

variable "service_principals" {
  type = map(object({
    sp_id        = string
    display_name = string
  }))
  default     = {}
  description = "list of service principals we want to create at Databricks account"
}

variable "account_groups" {
  type = map(object({
    group_name                     = string
    permissions                    = list(string)
  }))
  default     = {}
  description = "list of databricks account groups we want to assign to the workspace"
}

variable "storage_credential_id" {
  type        = string
  description = "the storage credential id"
}





