locals {
  databricks_managed = var.vpc_source == "databricks_managed"
  create_vpc         = var.vpc_source == "create"
  use_existing_vpc   = var.vpc_source == "existing"

  any_private_link = var.private_link_frontend || var.private_link_backend
  spoke_project    = coalesce(var.spoke_vpc_google_project, var.google_project)
}
