module "azure_databricks_demo" {
  source       = "../modules/azure-databricks-workspace"
  cluster_name = var.cluster_name
  department   = var.department
  user_name    = var.user_name
  group_name   = var.group_name
  prefix       = var.prefix
  tags = {
    Owner = "yassine.essawabi@databricks.com"
  }
}
