variable "overwatch_ws_name"{
    default = "overwatch-ws"
    description = "Name of the Azure Databricks Workspace that will be dedicated for Overwatch"
}

variable "adb_ws1" {
    description = "one of the workspaces that overwatch will monitor"
}

variable "adb_ws2" {
    description = "a second workspace that overwatch will monitor"
}

variable "rg_name" {
    description = "resource group name where the resources will be deployed"
}

variable "eventhub_name1" {
    description = "the eventhub that will receive the first workspace messages"
}

variable "eventhub_name2" {
    description = "the eventhub that will receive the second workspace messages"
}

variable "tenant_id" {
    description = ""
}

variable "overwatch_spn" {
    description = ""
}

variable "overwatch_spn_key" {
    description = ""
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

variable "service_principal_id_mount" {
    description = "ObjectID of the service principal that will be granted blob contributor role in the storage account of both logs and overwatch DB. This has to be the objectID of the service principal that will be used to mount the ADLS in the DBFS"
}

variable "logs_storage_account_name" {
    default = "overwatchlogs"
    description = "Main DataLake name"
}

variable "overwatch_storage_account_name" {
    default = "overwatchdb"
    description = "Main DataLake name"
}

variable "random_string" {
    description = "random string that will be added as a suffix to the resources names"
}

variable "overwatch_version" {
    description = "the overwatch library maven version"
    default = "overwatch_2.12:0.7.1.0"
}