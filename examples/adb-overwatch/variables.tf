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

variable "interactive_dbu_price" {
  default = 0.55
}

variable "automated_dbu_price" {
  default = 0.3
}

variable "sql_compute_dbu_price" {
  default = 0.22
}

variable "jobs_light_dbu_price" {
  default = 0.1
}

variable "max_days" {
  default = 30
}

variable "excluded_scopes" {
  default = ""
}

variable "active" {
  default = "TRUE"
}

variable "proxy_host" {
  default = ""
}

variable "proxy_port" {
  default = ""

}

variable "proxy_user_name" {
  default = ""
}

variable "proxy_password_scope" {
  default = ""
}

variable "proxy_password_key" {
  default = ""
}

variable "success_batch_size" {
  default = ""
}

variable "error_batch_size" {
  default = ""
}

variable "enable_unsafe_SSL" {
  default = ""
}

variable "thread_pool_size" {
  default = ""
}

variable "api_waiting_time" {
  default = ""
}