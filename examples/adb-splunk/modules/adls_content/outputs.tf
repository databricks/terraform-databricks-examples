output "storage_name" {
  value = azurerm_storage_account.personaldropbox.name
}

output "container_name" {
  value = azurerm_storage_container.example_container.name
}
