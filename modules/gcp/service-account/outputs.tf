output "service_account_email" {
  value       = google_service_account.this.email
  description = "Add this email as a user in the Databricks account console"
}
