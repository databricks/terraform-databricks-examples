variable "workspace_id" {
  type        = string
  description = "Id of the workspace"
}

variable "service_principals" {
  type = map(object({
    sp_id        = string
    display_name = optional(string)
    permissions  = list(string)
  }))
  default     = {}
  description = "list of service principals we want to create at Databricks account"
}

variable "account_groups" {
  type = map(object({
    group_name  = string
    permissions = list(string)
  }))
  default     = {}
  description = "list of databricks account groups we want to assign to the workspace"
}
