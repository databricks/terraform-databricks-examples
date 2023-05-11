variable "key_vault_id" {
  description = "The ID of the Key Vault to use for secrets"
  type        = string
}

variable "vault_uri" {
  description = "The DNS Name of the Key Vault to use for secrets"
  type        = string
}

variable "node_type" {
  description = "instance type"
  type        = string
  default     = "Standard_DS3_v2"
}

variable "db_username" {
  type      = string
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "workspace_url" {
  type = string
}

variable "metastoreserver" {
  description = "name of the metastore server"
  type        = string
}

variable "metastoredbname" {
  description = "name of the metastore database"
  type        = string
}
