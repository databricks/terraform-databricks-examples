output "arm_client_id" {
  value = data.azurerm_client_config.current.client_id
}

output "arm_subscription_id" {
  value = data.azurerm_client_config.current.subscription_id
}

output "arm_tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "azure_region" {
  value = local.location
}

output "resource_group" {
  value = azurerm_resource_group.this.name
}

output "tls_private_key" {
  value     = tls_private_key.squid_ssh.private_key_pem
  sensitive = true
}
