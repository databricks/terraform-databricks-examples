resource "google_compute_shared_vpc_host_project" "host" {
  count = var.create_hub && var.is_spoke_vpc_shared && var.workspace_google_project != var.spoke_vpc_google_project ? 1 : 0

  project = var.spoke_vpc_google_project
}

resource "google_compute_shared_vpc_service_project" "service" {
  count = var.create_hub && var.is_spoke_vpc_shared && var.workspace_google_project != var.spoke_vpc_google_project ? 1 : 0

  host_project    = google_compute_shared_vpc_host_project.host[0].project
  service_project = var.workspace_google_project
}
