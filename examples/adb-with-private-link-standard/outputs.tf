output "test_vm_password" {
  description = "Password to access the Test VM, use `terraform output -json test_vm_password` to get the password value"
  value       = module.adb-with-private-link-standard.test_vm_password
  sensitive   = true
}

output "test_vm_public_ip" {
  description = "Public IP of the Azure VM created for testing"
  value       = module.adb-with-private-link-standard.test_vm_public_ip
}

output "workspace_id" {
  description = "The Databricks workspace ID"
  value       = module.adb-with-private-link-standard.workspace_id
}

output "workspace_url" {
  description = "The Databricks workspace URL"
  value       = module.adb-with-private-link-standard.workspace_url
}