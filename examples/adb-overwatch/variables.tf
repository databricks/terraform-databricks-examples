variable "subscription_id" {
  description = "The Azure subscription ID"
}

variable "tenant_id" {
  description = "The Azure tenant ID"
}

variable "overwatch_spn_app_id" {
  description = "The Azure AD service principal (SPN) application ID that will be used to access the storage accounts"
}

variable "overwatch_spn_secret" {
  description = "The client secret for the Azure AD SPN"
}

variable "rg_name" {
    description = "resource group name where the resources will be deployed"
}

variable "adb_ws1" {
    description = "The name of the first workspace that overwatch will monitor"
}

variable "adb_ws2" {
    description = "The name of the second workspace that overwatch will monitor"
}

variable "eventhub_name" {
  description = "The eventhub name prefix used to build the names of the eventhubs for all the monitored workspaces"
  default = "eh-adb-overwatch"
}
