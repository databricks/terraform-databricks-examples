variable "subscription_id" {}

variable "tenant_id" {}

variable "service_principal_id_mount" {}

variable "overwatch_spn" {}

variable "overwatch_spn_pass" {}

variable "overwatch_spn_key" {}

variable "eventhub_name" {
  default = "eh-adb-overwatch"
}

variable "adb_ws1" {}

variable "adb_ws2" {}

variable "rg_name" {}