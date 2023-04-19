variable "subscription_id" {}

variable "rg_name" {}

variable "overwatch_ws_name" {}

variable "use_existing_ws" {
  description = "A boolean that determines to either use an existing Databricks workspace for Overwatch, when it is set to 'true', or create a new one when it is set to 'false'"
}