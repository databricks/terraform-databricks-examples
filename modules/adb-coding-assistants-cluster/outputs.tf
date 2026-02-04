output "cluster_id" {
  description = "The ID of the created cluster"
  value       = databricks_cluster.coding_assistants.id
}

output "cluster_url" {
  description = "URL to access the cluster in Databricks UI"
  value       = databricks_cluster.coding_assistants.url
}

output "cluster_name" {
  description = "Name of the created cluster"
  value       = databricks_cluster.coding_assistants.cluster_name
}

output "volume_path" {
  description = "Path to the volume containing init scripts"
  value       = databricks_volume.init_scripts.volume_path
}

output "volume_full_name" {
  description = "Full name of the volume"
  value       = "${var.catalog_name}.${var.schema_name}.${var.volume_name}"
}

output "init_script_path" {
  description = "Path to the init script in the volume"
  value       = databricks_file.init_script.path
}

output "mlflow_experiment_name" {
  description = "MLflow experiment name for tracing"
  value       = var.mlflow_experiment_name
}
