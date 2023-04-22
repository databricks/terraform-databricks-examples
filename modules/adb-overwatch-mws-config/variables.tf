variable "overwatch_ws_name" {
    type = string
    description = "Overwatch workspace name"
}

variable "rg_name" {
    type = string
    description = "Resource group name"
}

variable "overwatch_spn_app_id" {
    type = string
    description = "Azure SPN ID used to create the mount points"
}

variable "tenant_id" {
    type = string
    description = "Azure Tenant ID"
}

variable "ow_sa_name" {
    type = string
  description = "The name of the Overwatch ETL storage account"
}

variable "akv_name" {
    type = string
    description = "Azure Key-Vault name"
}

variable "databricks_secret_scope_name" {
    type = string
    description = "Databricks secret scope name (backed by Azure Key-Vault)"
}

variable "overwatch_job_notification_email"{
    default = "email@example.com"
    description = "Overwatch Job Notification Email"
}

variable "cron_job_schedule" {
    type = string
    default = "0 0 8 * * ?"
    description = "Cron expression to schedule the Overwatch Job"
}

variable "cron_timezone_id" {
    type = string
    default = "Europe/Brussels"
    description = "Timezone for the cron schedule"
}

variable "overwatch_version" {
    type = string
    description = "Overwatch library maven version"
    default = "overwatch_2.12:0.7.1.0"
}

variable "random_string" {
    type = string
    description = "Random string used as a suffix for the resources names"
}

variable "latest_dbr_lts" {
    type = string
    description = "Latest DBR LTS version"
}