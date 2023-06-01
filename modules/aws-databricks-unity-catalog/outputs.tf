output "metastore_id" {
  description = "Unity Catalog Metastore ID"
  value       = resource.databricks_metastore.this.id
}
