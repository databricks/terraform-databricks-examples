variable "subscription_id" {
  description = "Azure subscription id"
}
variable "databricks_workspace_name" {
  description = "Azure databricks workspace name"
}
variable "resource_group" {
  description = "Azure resource group"
}
variable "aad_groups" {
  description = "List of AAD groups that you want to add to Databricks account"
  type        = list(string)
}
variable "account_id" {
  description = "Azure databricks account id"
}
variable "prefix" {
  description = "Prefix to be used with resouce names"
}

