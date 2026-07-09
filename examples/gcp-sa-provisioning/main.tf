module "service_account" {
  source         = "../../modules/gcp/service-account"
  google_project = var.google_project
  prefix         = var.prefix
  delegate_from  = var.delegate_from
}
