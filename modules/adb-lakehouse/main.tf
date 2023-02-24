resource "azurerm_resource_group" "this" {
  name     = var.spoke_resource_group_name
  location = var.location
  tags     = var.tags
}

