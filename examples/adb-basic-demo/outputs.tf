output "databricks_azure_workspace_resource_id" {
  // The ID of the Databricks Workspace in the Azure management plane.
  value = azurerm_databricks_workspace.example.id
}

output "workspace_url" {
  // The workspace URL which is of the format 'adb-{workspaceId}.{random}.azuredatabricks.net'
  // this is not named as DATABRICKS_HOST, because it affect authentication
  value = "https://${azurerm_databricks_workspace.example.workspace_url}/"
}

output "module_cluster_id" {
  // reference to module's outputs: value = module.module_name.output_attr_name
  value = module.auto_scaling_cluster_example.cluster_id
}
