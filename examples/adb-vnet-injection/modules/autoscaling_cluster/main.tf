terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = ">=1.13.0"
    }
  }
}

resource "databricks_cluster" "shared_autoscaling" {
  cluster_name            = "Shared Autoscaling"
  spark_version           = var.spark_version
  node_type_id            = var.node_type_id
  autotermination_minutes = var.autotermination_minutes
  autoscale {
    min_workers = 1
    max_workers = 3
  }
}
