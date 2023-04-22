output "etl_storage_prefix" {
  description = "Overwatch ETL storage prefix, which represents a mount point to the ETL storage account"
  value = local.etl_storage_prefix
}

output "databricks_mount_db_name" {
  description = "Mount point name to the storage account where Overwatch will be writing the results"
  value = databricks_mount.overwatch_db.name
}