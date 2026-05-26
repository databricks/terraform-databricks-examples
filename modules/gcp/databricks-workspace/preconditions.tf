# Cross-variable preconditions.
resource "null_resource" "preconditions" {
  lifecycle {
    precondition {
      condition     = !var.restricted_egress || local.create_vpc
      error_message = "restricted_egress=true requires vpc_source=\"create\" (hub-spoke topology needs us to own both VPCs)."
    }
    precondition {
      condition     = !var.restricted_egress || local.any_private_link
      error_message = "restricted_egress=true requires at least one of private_link_frontend or private_link_backend."
    }
    precondition {
      condition     = !var.restricted_egress || (var.hub_vpc_google_project != null && var.hub_vpc_cidr != null && var.psc_subnet_cidr != null)
      error_message = "restricted_egress=true requires hub_vpc_google_project, hub_vpc_cidr, and psc_subnet_cidr."
    }
    precondition {
      condition     = !local.create_vpc || (var.spoke_vpc_cidr != null && var.subnet_cidr != null)
      error_message = "vpc_source=\"create\" requires spoke_vpc_cidr and subnet_cidr."
    }
    precondition {
      condition     = !local.use_existing_vpc || (var.existing_vpc_name != null && var.existing_subnet_name != null)
      error_message = "vpc_source=\"existing\" requires existing_vpc_name and existing_subnet_name."
    }
    precondition {
      condition     = !local.databricks_managed || (!var.private_link_frontend && !var.private_link_backend && !var.restricted_egress)
      error_message = "vpc_source=\"databricks_managed\" forbids private_link_frontend, private_link_backend, and restricted_egress."
    }
  }
}
