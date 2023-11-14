module "dev_compute_policy" {
  source = "../../common_modules_workspace/cluster_policy"
  team   = var.team
  policy_overrides = {
    "spark_conf.spark.databricks.io.cache.enabled" : {
      "type" : "fixed",
      "value" : "true"
    },
  }
}

module "workspace_config" {
  source = "../../common_modules_workspace/workspace_confs"
}