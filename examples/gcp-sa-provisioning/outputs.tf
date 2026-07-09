output "service_account" {
  value       = module.service_account.service_account_email
  description = "Add this email as a user in the Databricks account console"
}
