output "test_vm_password" {
  description = "Password to access the Test VM, use `terraform output -json test_vm_password` to get the password value"
  value       = module.adb-with-private-link-standard.test_vm_password
  sensitive   = true
}