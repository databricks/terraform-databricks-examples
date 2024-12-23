module "gcp-sa-provisioning" {
  source         = "github.com/databricks/terraform-databricks-examples/modules/gcp-sa-provisioning"
  google_project = var.google_project
  prefix         = var.prefix
  delegate_from  = var.delegate_from
}
