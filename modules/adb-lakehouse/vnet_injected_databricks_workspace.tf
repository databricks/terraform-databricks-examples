locals {
  service_delegation_actions = [
    "Microsoft.Network/virtualNetworks/subnets/join/action",
    "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
    "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
  ]
}

resource "azurerm_subnet" "private" {
  name                 = "private-subnet-${var.workspace_name}"
  resource_group_name  = var.databricks_resource_group_name
  virtual_network_name = var.vnet_name

  address_prefixes = var.private_subnet_address_prefixes

  delegation {
    name = "databricks-private-subnet-delegation"

    service_delegation {
      name    = "Microsoft.Databricks/workspaces"
      actions = local.service_delegation_actions
    }
  }
}

resource "azurerm_subnet" "public" {
  name                 = "public-subnet-${var.workspace_name}"
  resource_group_name  = var.databricks_resource_group_name
  virtual_network_name = var.vnet_name

  address_prefixes = var.public_subnet_address_prefixes

  delegation {
    name = "databricks-public-subnet-delegation"

    service_delegation {
      name    = "Microsoft.Databricks/workspaces"
      actions = local.service_delegation_actions
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "private" {
  subnet_id                 = azurerm_subnet.private.id
  network_security_group_id = var.nsg_id
}

resource "azurerm_subnet_network_security_group_association" "public" {
  subnet_id                 = azurerm_subnet.public.id
  network_security_group_id = var.nsg_id
}

resource "azurerm_subnet_route_table_association" "private" {
  subnet_id      = azurerm_subnet.private.id
  route_table_id = var.route_table_id
}

resource "azurerm_subnet_route_table_association" "public" {
  subnet_id      = azurerm_subnet.public.id
  route_table_id = var.route_table_id
}

resource "azurerm_monitor_diagnostic_setting" "diagnostic-settings-auditlog" {
  name               = "diag-settings-auditlog-${var.environment_name}"
  target_resource_id = azurerm_databricks_workspace.this.id
  storage_account_id = azurerm_storage_account.dls[2].id

  dynamic "log" {
    for_each = var.auditlog_categories
    content {
      category = log.value
      retention_policy {
        enabled = true
        days    = var.auditlog_retention_days
      }
    }
  }
}

resource "azurerm_databricks_workspace" "this" {
  name                = var.workspace_name
  resource_group_name = var.databricks_resource_group_name
  location            = var.location
  sku                 = "premium"

  custom_parameters {
    no_public_ip                                         = true
    virtual_network_id                                   = var.vnet_id
    private_subnet_name                                  = azurerm_subnet.private.name
    public_subnet_name                                   = azurerm_subnet.public.name
    private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.private.id
    public_subnet_network_security_group_association_id  = azurerm_subnet_network_security_group_association.public.id
  }

  tags = var.tags
}
