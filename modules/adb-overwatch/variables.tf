variable "tenant_id" {
  description = "The Azure tenant ID"
}

variable "rg_name" {
    description = "resource group name where the resources will be deployed"
}

variable "overwatch_spn_app_id" {
  description = "The Azure AD service principal (SPN) application ID that will be used to access the storage accounts"
}

variable "overwatch_spn_secret" {
  description = "The client secret for the Azure AD SPN"
}

variable "overwatch_ws_name"{
    default = "overwatch-ws"
    description = "The name of the Azure Databricks Workspace that will be dedicated for Overwatch"
}

variable "adb_ws1" {
    description = "The name of the first workspace that overwatch will monitor"
}

variable "adb_ws2" {
    description = "The name of the second workspace that overwatch will monitor"
}

variable "eventhub_name1" {
    description = "the eventhub that will receive the first workspace messages"
}

variable "eventhub_name2" {
    description = "the eventhub that will receive the second workspace messages"
}

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

variable "eventhub_namespace_name" {
    default = "eh-ns-overwatch"
    description = "Eventhub Namespace for Overwatch"
}

variable "logs_storage_account_name" {
    default = "overwatchlogs"
    description = "The storage account that will store the cluster logs"
}

variable "overwatch_storage_account_name" {
    default = "overwatchdb"
    description = "The storage account that will store the Overwatch ETL datalake"
}

variable "random_string" {
    description = "random string that will be added as a suffix to the resources names"
}

variable "overwatch_version" {
    description = "the overwatch library maven version"
    default = "overwatch_2.12:0.7.1.0"
}