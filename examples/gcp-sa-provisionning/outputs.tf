output "service_account" {
  value       = google_service_account.sa2.email
  description = "Add this email as a user in the Databricks account console"
}

output "custom_role_url" {
  value = "https://console.cloud.google.com/iam-admin/roles/details/projects%3C${data.google_client_config.current.project}%3Croles%3C${google_project_iam_custom_role.workspace_creator.role_id}"
}
