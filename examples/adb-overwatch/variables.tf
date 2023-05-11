variable "subscription_id" {
  type = string
  description = "Azure subscription ID"
}

variable "rg_name" {
  type = string
  description = "Resource group name"
}

variable "ehn_name" {
  type = string
  description = "Eventhubs namespace name"
}

variable "tenant_id" {
  type = string
  description = "Azure tenant ID"
}

variable "overwatch_spn_app_id" {
  type = string
  description = "Azure SPN application ID"
}

variable "overwatch_spn_secret" {
  type = string
  description = "Azure SPN secret"
}

variable "logs_sa_name" {
  type = string
  description = "Logs storage account name"
}

variable "ow_sa_name" {
  type = string
  description = "Overwatch ETL storage account name"
}

variable "key_vault_prefix" {
  type = string
  description = "AKV prefix"
}

variable "overwatch_ws_name" {
  type = string
  description = "Overwatch Databricks workspace name"
}

variable "databricks_secret_scope_name" {
  type = string
  description = "Databricks secret scope name (backed by Azure Key-Vault)"
  default = "overwatch-akv"
}

variable "use_existing_overwatch_ws" {
  type = string
  description = "Overwatch ETL storage prefix, which represents a mount point to the ETL storage account"
  default = false
}

variable "interactive_dbu_price" {
  type = number
  description = "Contract price for interactive DBUs"
  default = 0.55
}

variable "automated_dbu_price" {
  type = number
  description = "Contract price for automated DBUs"
  default = 0.3
}

variable "sql_compute_dbu_price" {
  type = number
  description = "Contract price for DBSQL DBUs"
  default = 0.22
}

variable "jobs_light_dbu_price" {
  type = number
  description = "Contract price for interactive DBUs"
  default = 0.1
}

variable "max_days" {
  type = number
  description = "This is the max incremental days that will be loaded. Usually only relevant for historical loading and rebuilds"
  default = 30
}

variable "excluded_scopes" {
  type = string
  description = "Scopes that should not be excluded from the pipelines"
  default = ""
}

variable "active" {
  type = bool
  description = "Whether or not the workspace should be validated / deployed"
  default = true
}

variable "proxy_host" {
  type = string
  description = "Proxy url for the workspace"
  default = ""
}

variable "proxy_port" {
  type = string
  description = "Proxy port for the workspace"
  default = ""

}

variable "proxy_user_name" {
  type = string
  description = "Proxy user name for the workspace"
  default = ""
}

variable "proxy_password_scope" {
  type = string
  description = "Scope which contains the proxy password key"
  default = ""
}

variable "proxy_password_key" {
  type = string
  description = "Key which contains proxy password"
  default = ""
}

variable "success_batch_size" {
  type = string
  description = "API Tunable - Indicates the size of the buffer on filling of which the result will be written to a temp location. This is used to tune performance in certain circumstance"
  default = ""
}

variable "error_batch_size" {
  type = string
  description = "API Tunable - Indicates the size of the error writer buffer containing API call errors"
  default = ""
}

variable "enable_unsafe_SSL" {
  type = string
  description = "API Tunable - Enables unsafe SSL"
  default = ""
}

variable "thread_pool_size" {
  type = string
  description = "API Tunable - Max number of API calls Overwatch is allowed to make in parallel"
  default = ""
}

variable "api_waiting_time" {
  type = string
  description = "API Tunable - Overwatch makes async api calls in parallel, api_waiting_time signifies the max wait time in case of no response received from the api call"
  default = ""
}

variable "auditlog_prefix_source_path" {
  type = string
  description = "Location of auditlog (AWS/GCP Only)"
  default = ""
}