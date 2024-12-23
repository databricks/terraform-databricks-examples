module "gcp-basic" {
  source         = "../modules/gcp-sa-provisioning"
  google_project = var.google_project
  prefix         = var.prefix
  delegate_from  = var.delegate_from
}
