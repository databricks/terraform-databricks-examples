variable "subscription_id" {}

variable "tenant_id" {}

variable "overwatch_spn_app_id" {}

variable "overwatch_spn_secret" {}

variable "eventhub_name" {
  default = "eh-adb-overwatch"
}

variable "adb_ws1" {}

variable "adb_ws2" {}

variable "rg_name" {}