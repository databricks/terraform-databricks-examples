output "pip" {
  description = "Public IP of the Kafka broker"
  value       = module.kafka_broker.vm_public_ip
}

output "azure_resource_group_id" {
  description = "The Azure resource group ID"
  value       = local.rg_id
}

output "workspace_id" {
  description = "The Databricks workspace ID"
  value       = azurerm_databricks_workspace.this.workspace_id
}

output "workspace_url" {
  description = "The Databricks workspace URL"
  value       = "https://${azurerm_databricks_workspace.this.workspace_url}/"
}
