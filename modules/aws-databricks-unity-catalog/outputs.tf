output "metastore_id" {
  description = "Unity Catalog Metastore ID"
  value       = databricks_metastore.this.id
}
