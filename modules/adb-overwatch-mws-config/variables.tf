variable "overwatch_ws_name" {}

variable "rg_name" {}

variable "overwatch_spn_app_id" {}

variable "tenant_id" {}

variable "ow_sa_name" {
  description = "The name of the Overwatch ETL storage account"
}

variable "akv_name" {}

variable "databricks_secret_scope_name" {}

variable "overwatch_job_notification_email"{
    default = "email@example.com"
    description = "Overwatch Job Notification Email"
}

variable "cron_job_schedule" {
    default = "0 0 8 * * ?"
    description = "Cron expression to schedule the Overwatch Job"
}

variable "cron_timezone_id" {
    default = "Europe/Brussels"
    description = "Timezone for the cron schedule. Check documentation about supported timezone formats"
}

variable "overwatch_version" {
    description = "the overwatch library maven version"
    default = "overwatch_2.12:0.7.1.0"
}

variable "random_string" {}

variable "latest_dbr_lts" {}