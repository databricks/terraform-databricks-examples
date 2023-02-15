resource "azurerm_databricks_workspace" "example" {
  name                = "${local.prefix}-workspace"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "premium"
  tags                = local.tags
  custom_parameters {
    no_public_ip             = var.no_public_ip
    storage_account_name     = local.dbfsname
    storage_account_sku_name = "Standard_LRS"
  }
}

resource "databricks_dbfs_file" "init" {
  source = "${path.module}/scripts/git_proxy_init.sh"
  path   = "/init-scripts/dp_git_proxy_init.sh"
}

data "databricks_spark_version" "latest_lts" {
  long_term_support = true
}

module "git_proxy_module_instance" {
  source                  = "./modules/git_proxy"
  cluster_name            = var.proxy_cluster_name
  spark_version           = data.databricks_spark_version.latest_lts.id
  node_type_id            = var.node_type
  autotermination_minutes = var.proxy_auto_termination_minute
  proxy_initscript_path   = databricks_dbfs_file.init.dbfs_path
  depends_on = [
    databricks_dbfs_file.init
  ]
}

resource "databricks_notebook" "flip_feature_flag_notebook" {
  source = "${path.module}/scripts/git_proxy_flip_feature_flag.py"
  path   = "/Shared/git_proxy_flip_feature_flag"
}

resource "databricks_job" "this" {
  name                = "run once git-proxy flip feature flag"
  existing_cluster_id = module.git_proxy_module_instance.cluster_id
  notebook_task {
    notebook_path = databricks_notebook.flip_feature_flag_notebook.path
  }
}
