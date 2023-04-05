# The Azure resource ID for the Databricks workspace where Unity Catalog will be deployed. It should be of the format /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/group1/providers/Microsoft.Databricks/workspaces/workspace1. To find the resource ID, navigate to your Databricks workspace in the Azure portal, select the JSON View link on the Overview page.
variable "databricks_resource_id" {
  description = "The Azure resource ID for the databricks workspace deployment. This is where unity catalog will be deployed"
}
variable "account_id" {
  description = "Azure databricks account id"
}
variable "aad_groups" {
  description = "List of AAD groups that you want to add to Databricks account"
  type        = list(string)
}
