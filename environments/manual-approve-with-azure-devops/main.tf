module "azure_databricks_demo" {
  source       = "../../modules/databricks-department-clusters"
  cluster_name = var.cluster_name
  department   = var.department
  user_names   = var.user_names
  group_name   = var.group_name
  tags         = var.tags
}
