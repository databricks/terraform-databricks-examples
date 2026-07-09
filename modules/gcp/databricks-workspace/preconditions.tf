# Cross-variable preconditions.
resource "terraform_data" "preconditions" {
  lifecycle {
    precondition {
      condition     = !var.restricted_egress || local.create_spoke
      error_message = "restricted_egress=true requires vpc_source.spoke=\"create\" (hub-spoke topology needs us to own the spoke VPC)."
    }
    precondition {
      condition     = !var.restricted_egress || local.any_private_link
      error_message = "restricted_egress=true requires at least one of private_link_frontend or private_link_backend."
    }
    precondition {
      condition     = var.private_link_frontend == var.private_link_backend
      error_message = "On GCP, private_link_frontend and private_link_backend must be enabled together: databricks_mws_networks.vpc_endpoints requires both dataplane_relay and rest_api endpoint references. (The flags stay independent in the cross-cloud contract for clouds that support single-sided PrivateLink.)"
    }
    precondition {
      condition     = !local.any_private_link || var.psc_subnet_cidr != null
      error_message = "psc_subnet_cidr is required when any private_link_* flag is true."
    }
    precondition {
      condition     = !var.restricted_egress || var.hub_vpc_google_project != null
      error_message = "restricted_egress=true requires hub_vpc_google_project."
    }
    precondition {
      condition     = !(var.restricted_egress && local.hub_source == "create") || var.hub_vpc_cidr != null
      error_message = "restricted_egress=true with vpc_source.hub=\"create\" requires hub_vpc_cidr."
    }
    precondition {
      condition     = !(var.restricted_egress && local.hub_source == "existing") || (var.existing_hub_vpc_name != null && var.existing_hub_subnet_name != null)
      error_message = "vpc_source.hub=\"existing\" requires existing_hub_vpc_name and existing_hub_subnet_name."
    }
    precondition {
      condition     = !local.create_spoke || (var.spoke_vpc_cidr != null && var.subnet_cidr != null)
      error_message = "vpc_source.spoke=\"create\" requires spoke_vpc_cidr and subnet_cidr."
    }
    precondition {
      condition     = !local.use_existing_spoke || (var.existing_vpc_name != null && var.existing_subnet_name != null)
      error_message = "vpc_source.spoke=\"existing\" requires existing_vpc_name and existing_subnet_name."
    }
    precondition {
      condition     = !local.databricks_managed || (!var.private_link_frontend && !var.private_link_backend && !var.restricted_egress)
      error_message = "vpc_source.spoke=\"databricks_managed\" forbids private_link_frontend, private_link_backend, and restricted_egress."
    }
    precondition {
      condition = (
        !local.any_private_link && !var.restricted_egress
        ) || contains([
          "asia-northeast1", "asia-south1", "asia-southeast1", "australia-southeast1",
          "europe-west1", "europe-west2", "europe-west3", "northamerica-northeast1",
          "southamerica-east1", "us-central1", "us-east1", "us-east4", "us-west1", "us-west4"
      ], var.google_region)
      error_message = "google_region must be a region supported by Databricks PSC when any private_link_* flag or restricted_egress is true."
    }
    precondition {
      condition     = var.serverless_egress_mode == "restricted" || (length(var.serverless_allowed_internet_destinations) == 0 && length(var.serverless_allowed_storage_destinations) == 0)
      error_message = "serverless_allowed_internet_destinations and serverless_allowed_storage_destinations require serverless_egress_mode=\"restricted\"."
    }
  }
}
