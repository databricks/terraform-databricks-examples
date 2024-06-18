variable "adb_ws_name" {
  type = string
  description = "The name of an existing Databricks workspace that Overwatch will monitor"
}

variable "rg_name" {
  type = string
  description = "Resource group name"
}

variable "ehn_name" {
  type = string
  description = "Eventhub namespace name"
}

variable "tenant_id" {
  type = string
  description = "Azure tenant ID"
}

variable "overwatch_spn_app_id" {
  type = string
  description = "Azure SPN used to create Databricks mounts"
}

variable "ehn_auth_rule_name" {
  type = string
  description = "Eventhub namespace authorization rule name"
}

variable "logs_sa_name" {
  type = string
  description = "Logs storage account name"
}

variable "random_string" {
    type = string
    description = "Random string used as a suffix for the resources names"
}

variable "akv_name" {
  type = string
  description = "Azure Key-Vault name"
}

variable "databricks_secret_scope_name" {
  type = string
  description = "Databricks secret scope name (backed by Azure Key-Vault)"
}

variable "etl_storage_prefix" {
  type = string
  description = "Overwatch ETL storage prefix, which represents a mount point to the ETL storage account"
}

variable "interactive_dbu_price" {
  type = number
  description = "Contract price for interactive DBUs"
}

variable "automated_dbu_price" {
  type = number
  description = "Contract price for automated DBUs"
}

variable "sql_compute_dbu_price" {
  type = number
  description = "Contract price for DBSQL DBUs"
}

variable "jobs_light_dbu_price" {
  type = number
  description = "Contract price for interactive DBUs"
}

variable "max_days" {
  type = number
  description = "This is the max incremental days that will be loaded. Usually only relevant for historical loading and rebuilds"
}

variable "excluded_scopes" {
  type = string
  description = "Scopes that should not be excluded from the pipelines"
}

variable "active" {
  type = bool
  description = "Whether or not the workspace should be validated / deployed"
}

variable "proxy_host" {
  type = string
  description = "Proxy url for the workspace"
}

variable "proxy_port" {
  type = string
  description = "Proxy port for the workspace"
}

variable "proxy_user_name" {
  type = string
  description = "Proxy user name for the workspace"
}

variable "proxy_password_scope" {
  type = string
  description = "Scope which contains the proxy password key"
}

variable "proxy_password_key" {
  type = string
  description = "Key which contains proxy password"
}

variable "success_batch_size" {
  type = string
  description = "API Tunable - Indicates the size of the buffer on filling of which the result will be written to a temp location. This is used to tune performance in certain circumstance"
}

variable "error_batch_size" {
  type = string
  description = "API Tunable - Indicates the size of the error writer buffer containing API call errors"
}

variable "enable_unsafe_SSL" {
  type = string
  description = "API Tunable - Enables unsafe SSL"
}

variable "thread_pool_size" {
  type = string
  description = "API Tunable - Max number of API calls Overwatch is allowed to make in parallel"
}

variable "api_waiting_time" {
  type = string
  description = "API Tunable - Overwatch makes async api calls in parallel, api_waiting_time signifies the max wait time in case of no response received from the api call"
}

variable "auditlog_prefix_source_path" {
  type = string
  description = "Location of auditlog (AWS/GCP Only)"
}