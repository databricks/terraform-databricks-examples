# Dedicated gateway subnet, delegated to Azure Databricks. The private network
# gateway injects its network interfaces here. The subnet must not be used by
# any other Azure resource.
resource "azurerm_subnet" "gateway" {
  name                 = var.gateway_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = [var.gateway_subnet_address_prefix]

  delegation {
    name = "databricks-private-network-gateway"
    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
      ]
    }
  }

  lifecycle {
    precondition {
      condition     = !var.attach_nat_gateway || var.nat_gateway_id != null
      error_message = "attach_nat_gateway = true requires nat_gateway_id."
    }
  }
}

# Optional egress path for internet-bound traffic that enters the gateway, for
# example in ALL_TRAFFIC mode. Without a NAT gateway (or a firewall route) the
# gateway subnet has no outbound internet access.
resource "azurerm_subnet_nat_gateway_association" "gateway" {
  count          = var.attach_nat_gateway ? 1 : 0
  subnet_id      = azurerm_subnet.gateway.id
  nat_gateway_id = var.nat_gateway_id
}

# Gateway delete returns immediately, but the gateway keeps its network
# interface in the subnet and stays attached to the NCC while cleanup runs.
# Deleting the subnet or the NCC during that window fails. On destroy this
# resource waits after the gateway is deleted and before the subnet, the NAT
# association and (through the trigger) the NCC are deleted.
resource "time_sleep" "wait_for_gateway_cleanup" {
  destroy_duration = var.gateway_destroy_wait

  triggers = {
    network_connectivity_config_id = var.network_connectivity_config_id
    gateway_subnet_id              = azurerm_subnet.gateway.id
  }

  depends_on = [azurerm_subnet_nat_gateway_association.gateway]
}

resource "databricks_private_network_gateway" "this" {
  parent       = "accounts/${var.databricks_account_id}/network-connectivity-configs/${time_sleep.wait_for_gateway_cleanup.triggers["network_connectivity_config_id"]}"
  display_name = var.display_name
  traffic_mode = var.traffic_mode

  bandwidth_tier_gigabits_per_second = var.bandwidth_tier_gbps

  private_dns_resolvers = length(var.private_dns_resolvers) == 0 ? null : [
    for ip in var.private_dns_resolvers : {
      resolver_type = "IP_ADDRESS"
      value         = ip
    }
  ]

  destinations = length(var.destinations) == 0 ? null : [
    for d in var.destinations : {
      destination_type = "DNS_NAME"
      value            = d
    }
  ]

  azure_cloud_connection = {
    gateway_subnet = {
      resource_id = time_sleep.wait_for_gateway_cleanup.triggers["gateway_subnet_id"]
    }
  }

  lifecycle {
    precondition {
      condition     = var.traffic_mode != "SPECIFIC_DESTINATIONS" || (length(var.destinations) >= 1 && length(var.destinations) <= 100)
      error_message = "traffic_mode SPECIFIC_DESTINATIONS requires between 1 and 100 destinations."
    }
    precondition {
      condition     = var.traffic_mode != "ALL_TRAFFIC" || length(var.destinations) == 0
      error_message = "traffic_mode ALL_TRAFFIC routes all remaining serverless egress through the gateway. Leave destinations empty and add the intended destinations to the serverless egress network policy instead."
    }
  }
}
