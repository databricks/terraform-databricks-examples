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

variable "landing_adls_rg" {
  type        = string
  description = "The resource group name of the landing zone"
}

variable "storage_credential_name" {
  type        = string
  description = "the name of the storage credential"
}

variable "metastore_id" {
  type        = string
  description = "Id of the metastore"
}

variable "metastore_admins" {
  type        = list(string)
  description = "list of principals: service principals or groups that have metastore admin privileges"
}

variable "access_connector_id" {
  type        = string
  description = "the id of the access connector"
}
