# =============================================================================
# Application Gateway v2 — TCP/TLS proxy listener + native Private Link
#
# The azapi provider is used because azurerm does not expose TCP listeners.
# The TCP/TLS listener passes TLS through end-to-end (it does NOT terminate
# TLS) — the App Gateway sees only encrypted bytes. Works for Kafka and any
# other TLS-over-TCP workload.
#
# App GW v2 (Standard_v2) requires a public IP frontend unless the subscription
# has the EnableApplicationGatewayNetworkIsolation feature registered. The
# public IP is created to satisfy the SKU; the Private Link surface (used by the
# Databricks private endpoint) is attached to that frontend.
# =============================================================================

locals {
  appgw_base_id = "${azurerm_resource_group.this.id}/providers/Microsoft.Network/applicationGateways/${var.appgw_name}"
  frontend_port = "port-${var.listener_port}"
}

resource "azurerm_public_ip" "appgw" {
  name                = "pip-${var.appgw_name}"
  location            = var.azure_region
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

resource "azapi_resource" "appgw" {
  type      = "Microsoft.Network/applicationGateways@2024-05-01"
  name      = var.appgw_name
  location  = var.azure_region
  parent_id = azurerm_resource_group.this.id
  tags      = local.tags

  body = {
    properties = {
      sku = {
        name     = "Standard_v2"
        tier     = "Standard_v2"
        capacity = var.appgw_capacity
      }

      gatewayIPConfigurations = [{
        name       = "appgw-ip-config"
        properties = { subnet = { id = azurerm_subnet.appgw.id } }
      }]

      frontendIPConfigurations = [
        {
          name = local.frontend_pl_name
          properties = {
            publicIPAddress          = { id = azurerm_public_ip.appgw.id }
            privateLinkConfiguration = { id = "${local.appgw_base_id}/privateLinkConfigurations/${local.pl_config_name}" }
          }
        },
        {
          name = "frontend-private"
          properties = {
            privateIPAllocationMethod = "Static"
            privateIPAddress          = var.appgw_frontend_private_ip
            subnet                    = { id = azurerm_subnet.appgw.id }
          }
        }
      ]

      frontendPorts = [{
        name       = local.frontend_port
        properties = { port = var.listener_port }
      }]

      backendAddressPools = [{
        name = "backend-pool"
        properties = {
          backendAddresses = [for addr in var.backend_addresses : { ipAddress = addr }]
        }
      }]

      backendSettingsCollection = [{
        name = "backend-settings-tcp"
        properties = {
          port     = local.backend_port
          protocol = "Tcp"
          timeout  = 60
        }
      }]

      listeners = [{
        name = local.listener_name
        properties = {
          frontendIPConfiguration = { id = "${local.appgw_base_id}/frontendIPConfigurations/${local.frontend_pl_name}" }
          frontendPort            = { id = "${local.appgw_base_id}/frontendPorts/${local.frontend_port}" }
          protocol                = "Tcp"
        }
      }]

      routingRules = [{
        name = "rule-tcp"
        properties = {
          ruleType           = "Basic"
          priority           = 100
          listener           = { id = "${local.appgw_base_id}/listeners/${local.listener_name}" }
          backendAddressPool = { id = "${local.appgw_base_id}/backendAddressPools/backend-pool" }
          backendSettings    = { id = "${local.appgw_base_id}/backendSettingsCollection/backend-settings-tcp" }
        }
      }]

      privateLinkConfigurations = [{
        name = local.pl_config_name
        properties = {
          ipConfigurations = [{
            name = "pl-ipconfig"
            properties = {
              privateIPAllocationMethod = "Dynamic"
              primary                   = true
              subnet                    = { id = azurerm_subnet.appgw_pls.id }
            }
          }]
        }
      }]
    }
  }

  depends_on = [
    azurerm_subnet.appgw,
    azurerm_subnet.appgw_pls,
    azurerm_public_ip.appgw,
  ]
}
