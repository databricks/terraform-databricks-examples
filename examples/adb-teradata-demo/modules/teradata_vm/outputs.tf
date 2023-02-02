output "vm_public_ip" {
  value = azurerm_public_ip.teradata-nic-pubip.ip_address
}
