output "workspace_url" {
  description = "The Databricks workspace URL"
  value       = module.adb-data-storage-vnet-ncc-public-endpoint.databricks_host
}

