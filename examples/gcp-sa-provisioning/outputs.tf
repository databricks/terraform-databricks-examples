output "service_account" {
  value       = module.gcp-sa-provisioning.service_account
  description = "Add this email as a user in the Databricks account console"
}
