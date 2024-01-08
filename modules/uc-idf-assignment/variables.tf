variable "metastore_id" {
  type        = string
  description = "the id of the metastore"
}

variable "workspace_id" {
  type        = string
  description = "the id of the workspace"
}

variable "account_groups" {
  type = map(object({
    group_name  = string
    permissions = list(string)
  }))
  default     = {}
  description = "list of databricks account groups we want to assign to the workspace"
}

variable "service_principals" {
  type = map(object({
    sp_id        = string
    display_name = optional(string)
    permissions  = list(string)
  }))
  default     = {}
  description = "list of account-level service principals we want to assign to the workspace"
}
