# Data source to get current user
data "databricks_current_user" "me" {}

# Local value for init script path
locals {
  init_script_path = var.init_script_source_path != null ? var.init_script_source_path : "${path.module}/scripts/install-claude-offline.sh"
}

# Create or reference the volume for init scripts
resource "databricks_volume" "init_scripts" {
  name         = var.volume_name
  catalog_name = var.catalog_name
  schema_name  = var.schema_name
  volume_type  = "MANAGED"
  comment      = "Volume for Claude Code CLI offline init scripts"

  lifecycle {
    ignore_changes = [owner]
  }
}

# Upload the init script to the volume
resource "databricks_file" "init_script" {
  source = local.init_script_path
  path   = "${databricks_volume.init_scripts.volume_path}/install-claude-offline.sh"
}

# Create the cluster with init script
resource "databricks_cluster" "coding_assistants" {
  cluster_name            = var.cluster_name
  spark_version           = var.spark_version
  node_type_id            = var.node_type_id
  autotermination_minutes = var.autotermination_minutes
  data_security_mode      = "SINGLE_USER"
  single_user_name        = data.databricks_current_user.me.user_name

  # Autoscaling or fixed size
  dynamic "autoscale" {
    for_each = var.num_workers == null ? [1] : []
    content {
      min_workers = var.min_workers
      max_workers = var.max_workers
    }
  }

  num_workers = var.num_workers

  # Single node configuration
  spark_conf = var.cluster_mode == "SINGLE_NODE" ? {
    "spark.databricks.cluster.profile" = "singleNode"
    "spark.master"                     = "local[*]"
  } : {}

  custom_tags = merge(
    var.tags,
    {
      "ManagedBy" = "Terraform"
    },
    var.cluster_mode == "SINGLE_NODE" ? {
      "ResourceClass" = "SingleNode"
    } : {}
  )

  # Environment variables for Claude Code CLI
  spark_env_vars = merge(
    {
      MLFLOW_EXPERIMENT_NAME = var.mlflow_experiment_name
    },
    var.offline_packages_path != null ? {
      OFFLINE_PACKAGES_PATH = var.offline_packages_path
    } : {}
  )

  # Init script configuration
  init_scripts {
    volumes {
      destination = "${databricks_volume.init_scripts.volume_path}/install-claude-offline.sh"
    }
  }

  depends_on = [
    databricks_file.init_script
  ]
}
