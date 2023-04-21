output "etl_storage_prefix" {
  value = local.etl_storage_prefix
}

output "databricks_mount_db_name" {
  value = databricks_mount.overwatch_db.name
}