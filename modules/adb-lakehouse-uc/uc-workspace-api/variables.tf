variable "environment_name" {
  type        = string
  description = "the deployment environment"
}

variable "landing_external_location_name" {
  type        = string
  description = "the name of the landing external location"
}

variable "landing_adls_path" {
  type        = string
  description = "The ADLS path of the landing zone"
}

variable "storage_credential_id" {
  type        = string
  description = "the storage credential id"
}

variable "metastore_id" {
  type        = string
  description = "Id of the metastore"
}

variable "metastore_admins" {
  type        = list(string)
  description = "list of principals: service principals or groups that have metastore admin privileges"
}





