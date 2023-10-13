module "gcp-byovpc" {
  source                = "github.com/databricks/terraform-databricks-examples/modules/gcp-workspace-byovpc"
  databricks_account_id = var.databricks_account_id
  google_project        = var.google_project
  google_region         = var.google_region
  prefix                = var.prefix
  subnet_ip_cidr_range  = var.subnet_ip_cidr_range
  pod_ip_cidr_range     = var.pod_ip_cidr_range
  svc_ip_cidr_range     = var.svc_ip_cidr_range
  subnet_name           = var.subnet_name
  router_name           = var.router_name
  nat_name              = var.nat_name
  workspace_name        = var.workspace_name
  delegate_from         = var.delegate_from
}
