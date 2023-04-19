variable "subscription_id" {}

variable "rg_name" {}

variable "ehn_name" {}

variable "tenant_id" {}

variable "object_id" {}

variable "overwatch_spn_app_id" {}

variable "overwatch_spn_secret" {}

variable "logs_sa_name" {}

variable "ow_sa_name" {}

variable "key_vault_prefix" {}

variable "overwatch_ws_name" {}

variable "databricks_secret_scope_name" {
  default = "overwatch-akv"
}

variable "use_existing_overwatch_ws" {
  description = "A boolean that determines to either use an existing Databricks workspace for Overwatch, when it is set to 'true', or create a new one when it is set to 'false'"
  default = false
}