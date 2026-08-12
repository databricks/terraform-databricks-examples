resource "google_service_account" "this" {
  account_id   = "${var.prefix}-ws-creator"
  display_name = "Service Account for Databricks Provisioning"
}

data "google_iam_policy" "this" {
  binding {
    role    = "roles/iam.serviceAccountTokenCreator"
    members = var.delegate_from
  }
}

resource "google_service_account_iam_policy" "impersonatable" {
  service_account_id = google_service_account.this.name
  policy_data        = data.google_iam_policy.this.policy_data
}

resource "google_project_iam_custom_role" "workspace_creator" {
  role_id = "${var.prefix}_workspace_creator"
  title   = "Databricks Workspace Creator"
  project = var.google_project
  # Current workspace-creator permission set (managed VPC + BYOVPC union): https://docs.databricks.com/gcp/en/admin/cloud-configurations/gcp/permissions
  # GKE-era container.*/storage.* permissions were removed: the data plane is GCE and
  # Databricks service agents provision workspace infrastructure.
  permissions = [
    "compute.firewalls.create",
    "compute.firewalls.get",
    "compute.firewalls.update",
    "compute.networks.get",
    "compute.networks.updatePolicy",
    "compute.projects.get",
    "compute.subnetworks.get",
    "compute.subnetworks.getIamPolicy",
    "compute.subnetworks.setIamPolicy",
    "iam.roles.create",
    "iam.roles.delete",
    "iam.roles.get",
    "iam.roles.update",
    "iam.serviceAccounts.create",
    "iam.serviceAccounts.get",
    "iam.serviceAccounts.getIamPolicy",
    "iam.serviceAccounts.setIamPolicy",
    "resourcemanager.projects.get",
    "resourcemanager.projects.getIamPolicy",
    "resourcemanager.projects.setIamPolicy",
    "serviceusage.services.enable",
    "serviceusage.services.get",
    "serviceusage.services.list",
  ]
}

resource "google_project_iam_member" "workspace_creator" {
  role    = google_project_iam_custom_role.workspace_creator.id
  member  = "serviceAccount:${google_service_account.this.email}"
  project = var.google_project
}
