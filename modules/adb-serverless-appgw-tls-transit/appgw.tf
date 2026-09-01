# Application Gateway v2 TCP/TLS proxy listener + native Private Link.
# azurerm does not currently expose the TCP listener properties, so the
# Application Gateway is represented with AzAPI.

locals {
  appgw_base_id = "${azurerm_resource_group.this.id}/providers/Microsoft.Network/applicationGateways/${var.appgw_name}"
  listener_name = "listener-tls"
  frontend_name = "frontend-private"
  frontend_port = "port-${var.listener_port}"
  pl_name       = "privatelink-config"
  backend_port  = coalesce(var.backend_port, var.listener_port)

  # Derive the listener address from the subnet so it cannot accidentally be
  # configured outside the Application Gateway subnet.
  appgw_frontend_private_ip = cidrhost(var.appgw_subnet_prefix, 10)

  backend_addresses = [
    for address in var.backend_addresses : {
      ipAddress = address
    }
  ]

  backend_fqdns = [
    for fqdn in var.backend_fqdns : {
      fqdn = fqdn
    }
  ]
}

resource "azurerm_public_ip" "appgw" {
  name                = "pip-${var.appgw_name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

resource "azapi_resource" "appgw" {
  type      = "Microsoft.Network/applicationGateways@2024-05-01"
  name      = var.appgw_name
  location  = azurerm_resource_group.this.location
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

      # The public frontend is intentionally unused. Standard_v2 currently
      # requires a public IP resource for GatewayManager communication, while
      # the listener and the Private Link association use the private frontend.
      frontendIPConfigurations = [
        {
          name = local.frontend_name
          properties = {
            privateIPAllocationMethod = "Static"
            privateIPAddress          = local.appgw_frontend_private_ip
            subnet                    = { id = azurerm_subnet.appgw.id }
            privateLinkConfiguration  = { id = "${local.appgw_base_id}/privateLinkConfigurations/${local.pl_name}" }
          }
        },
        {
          name       = "frontend-public-unused"
          properties = { publicIPAddress = { id = azurerm_public_ip.appgw.id } }
        }
      ]

      frontendPorts = [{
        name       = local.frontend_port
        properties = { port = var.listener_port }
      }]

      backendAddressPools = [{
        name = "backend-pool"
        properties = {
          backendAddresses = concat(local.backend_addresses, local.backend_fqdns)
        }
      }]

      probes = [{
        name = "probe-tcp"
        properties = {
          protocol           = "Tcp"
          port               = local.backend_port
          interval           = 30
          timeout            = 30
          unhealthyThreshold = 3
        }
      }]

      backendSettingsCollection = [{
        name = "backend-settings-tcp"
        properties = {
          port     = local.backend_port
          protocol = "Tcp"
          timeout  = 60
          probe    = { id = "${local.appgw_base_id}/probes/probe-tcp" }
        }
      }]

      listeners = [{
        name = local.listener_name
        properties = {
          frontendIPConfiguration = { id = "${local.appgw_base_id}/frontendIPConfigurations/${local.frontend_name}" }
          frontendPort            = { id = "${local.appgw_base_id}/frontendPorts/${local.frontend_port}" }
          protocol                = "Tcp"
        }
      }]

      routingRules = [{
        name = "rule-tls"
        properties = {
          ruleType           = "Basic"
          priority           = 100
          listener           = { id = "${local.appgw_base_id}/listeners/${local.listener_name}" }
          backendAddressPool = { id = "${local.appgw_base_id}/backendAddressPools/backend-pool" }
          backendSettings    = { id = "${local.appgw_base_id}/backendSettingsCollection/backend-settings-tcp" }
        }
      }]

      privateLinkConfigurations = [{
        name = local.pl_name
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
    azurerm_subnet_network_security_group_association.appgw,
    azurerm_public_ip.appgw,
  ]
}
