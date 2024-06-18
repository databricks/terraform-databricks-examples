variable "subscription_id" {
  type = string
  description = "Azure subscription ID"
}

variable "rg_name" {
  type = string
  description = "Resource group name"
}

variable "overwatch_ws_name" {
  type = string
  description = "The name of an existing workspace, or the name to use to create a new one for Overwatch"
}

variable "use_existing_ws" {
  type = bool
  description = "A boolean that determines to either use an existing Databricks workspace for Overwatch, when it is set to true, or create a new one when it is set to false"
}