variable "rg_name" {
  type = string
  description = "Resource group name"
}

variable "random_string" {
    type = string
    description = "Random string used as a suffix for the resources names"
}

variable "logs_sa_name" {
  description = "Logs storage account name"
}

variable "overwatch_spn_app_id" {
    type = string
    description = "Azure SPN ID used to create the mount points"
}

variable "overwatch_spn_secret" {
  type = string
  description = "Azure SPN secret"
}

variable "ehn_name" {
  description = "Eventhubs namespace name"
}

variable "key_vault_prefix" {
  type = string
  description = "AKV prefix to use when creating the resource"
}