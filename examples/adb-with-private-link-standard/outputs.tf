output "databricks_workspace_url" {
  value = module.adb-with-private-link-standard.dp_workspace_url
}

output "test_vm_password" {
  description = "Password to access the VM, use `terraform output -json test_vm_password` to get the password value"
  value = module.adb-with-private-link-standard.test_vm_password
  sensitive = true
}