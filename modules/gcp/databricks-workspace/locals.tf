locals {
  databricks_managed = var.vpc_source == "databricks_managed"
  create_vpc         = var.vpc_source == "create"
  use_existing_vpc   = var.vpc_source == "existing"

  any_private_link = var.private_link_frontend || var.private_link_backend
  spoke_project    = coalesce(var.spoke_vpc_google_project, var.google_project)

  # Both submodules below consume module.network[0] outputs (spoke/hub VPC refs), which
  # don't exist when vpc_source="databricks_managed". Valid configs never combine
  # databricks_managed with any_private_link/restricted_egress (see preconditions.tf), but
  # negative fixtures deliberately do; gating on !databricks_managed here (in addition to the
  # precondition) keeps plan from cascading into "Invalid index" / "Missing required argument"
  # errors before the precondition message is shown.
  private_connectivity_enabled = local.any_private_link && !local.databricks_managed
  dns_enabled                  = var.restricted_egress && !local.databricks_managed
}
