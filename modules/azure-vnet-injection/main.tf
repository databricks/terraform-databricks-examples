/**
 * Azure Databricks workspace in custom VNet
 *
 * Module creates:
 * * Resource group with random prefix
 * * Tags, including `Owner`, which is taken from `az account show --query user`
 * * VNet with public and private subnet
 * * Databricks workspace
 */


data "azurerm_client_config" "current" {
}


resource "azurerm_resource_group" "this" {
  name     = "${var.prefix}-rg"
  location = var.location
  tags     = var.tags
}

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
  value = var.location
}

output "test_resource_group" {
  value = azurerm_resource_group.this.name
}