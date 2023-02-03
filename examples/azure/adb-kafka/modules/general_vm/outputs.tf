output "vm_public_ip" {
  value = azurerm_public_ip.general-nic-pubip.ip_address
}
