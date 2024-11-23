output "vm_public_ip" {
  description = "Public IP of the VM"
  value       = azurerm_public_ip.general-nic-pubip.ip_address
}
