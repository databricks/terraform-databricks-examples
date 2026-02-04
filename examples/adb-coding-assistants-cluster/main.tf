# Cluster with Claude Code CLI coding assistant
# Provider configuration is in providers.tf
module "claude_cluster" {
  source = "../../modules/adb-coding-assistants-cluster"

  cluster_name                = var.cluster_name
  catalog_name                = var.catalog_name
  schema_name                 = var.schema_name
  volume_name                 = var.volume_name
  init_script_source_path     = var.init_script_source_path
  spark_version               = var.spark_version
  node_type_id                = var.node_type_id
  autotermination_minutes     = var.autotermination_minutes
  num_workers                 = var.num_workers
  min_workers                 = var.min_workers
  max_workers                 = var.max_workers
  mlflow_experiment_name      = var.mlflow_experiment_name
  cluster_mode                = var.cluster_mode
  tags                        = var.tags
}

