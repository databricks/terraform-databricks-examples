resource "azurerm_eventhub_namespace" "ehn" {
  name                = join("", [var.eventhub_namespace_name, "-", var.random_string])
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "Basic"
  capacity            = 1

  tags = {
    environment = "Overwatch"
  }
}

resource "azurerm_eventhub_namespace_authorization_rule" "ehnar" {
  name                = "overwatch-eh-ns-auth-rule"
  namespace_name      = azurerm_eventhub_namespace.ehn.name
  resource_group_name = data.azurerm_resource_group.rg.name
  listen              = true
  send                = true
  manage              = true
}

data "azurerm_eventhub_namespace" "ehn" {
  name = azurerm_eventhub_namespace.ehn.name
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_eventhub" "eh1" {
  name                = var.eventhub_name1
  namespace_name      = azurerm_eventhub_namespace.ehn.name
  resource_group_name = data.azurerm_resource_group.rg.name
  partition_count     = 2
  message_retention   = 1
}

resource "azurerm_eventhub_authorization_rule" "eh1-ar" {
  name                = "overwatch-eh1-auth-rule"
  namespace_name      = azurerm_eventhub_namespace.ehn.name
  eventhub_name       = azurerm_eventhub.eh1.name
  resource_group_name = data.azurerm_resource_group.rg.name
  listen              = true
  send                = true
  manage              = true
}
/*
data "azurerm_eventhub_authorization_rule" "eh1-ar" {
  name = azurerm_eventhub_authorization_rule.eh1-ar.name
  resource_group_name = azurerm_resource_group.rg.name
  namespace_name      = azurerm_eventhub_namespace.ehn.name
  eventhub_name       = azurerm_eventhub.eh1.name
}*/

resource "azurerm_eventhub" "eh2" {
  name                = var.eventhub_name2
  namespace_name      = azurerm_eventhub_namespace.ehn.name
  resource_group_name = data.azurerm_resource_group.rg.name
  partition_count     = 2
  message_retention   = 1
}

resource "azurerm_eventhub_authorization_rule" "eh2-ar" {
  name                = "overwatch-eh2-auth-rule"
  namespace_name      = azurerm_eventhub_namespace.ehn.name
  eventhub_name       = azurerm_eventhub.eh2.name
  resource_group_name = data.azurerm_resource_group.rg.name
  listen              = true
  send                = true
  manage              = true
}

/*data "azurerm_eventhub_authorization_rule" "eh2-ar" {
  name = azurerm_eventhub_authorization_rule.eh2-ar.name
  resource_group_name = azurerm_resource_group.rg.name
  namespace_name      = azurerm_eventhub_namespace.ehn.name
  eventhub_name       = azurerm_eventhub.eh2.name
}*/
