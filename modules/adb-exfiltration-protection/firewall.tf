resource "azurerm_public_ip" "fwpublicip" {
  name                = "hubfirewallpublicip"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

resource "azurerm_firewall" "hubfw" {
  name                = "hubfirewall"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  tags                = local.tags

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.hubfw.id
    public_ip_address_id = azurerm_public_ip.fwpublicip.id
  }
}

locals {
  metastore_ips = toset(flatten([for k, v in data.dns_a_record_set.metastore : v.addrs]))
  eventhubs_ips = toset(flatten([for k, v in data.dns_a_record_set.eventhubs : v.addrs]))
  scc_relay_ips = toset(flatten([for k, v in data.dns_a_record_set.scc_relay : v.addrs]))
}

data "dns_a_record_set" "metastore" {
  for_each = toset(var.metastore)
  host     = each.value
}

data "dns_a_record_set" "eventhubs" {
  for_each = toset(var.eventhubs)
  host     = each.value
}

data "dns_a_record_set" "scc_relay" {
  for_each = toset(var.scc_relay)
  host     = each.value
}

resource "azurerm_firewall_network_rule_collection" "adbfnetwork" {
  name                = "adbcontrolplanenetwork"
  azure_firewall_name = azurerm_firewall.hubfw.name
  resource_group_name = azurerm_resource_group.this.name
  priority            = 200
  action              = "Allow"

  rule {
    name = "databricks-webapp"

    source_addresses = [
      join(", ", azurerm_subnet.public.address_prefixes),
      join(", ", azurerm_subnet.private.address_prefixes),
    ]

    destination_ports = [
      "443", "8443", "8444",
    ]

    destination_addresses = var.webapp_ips

    protocols = [
      "TCP",
    ]
  }

  rule {
    name = "databricks-extended_infra"

    source_addresses = [
      join(", ", azurerm_subnet.public.address_prefixes),
      join(", ", azurerm_subnet.private.address_prefixes),
    ]

    destination_addresses = [var.extended_infra_ip]
    destination_ports     = ["*"]
    protocols = [
      "TCP",
    ]
  }

  rule {
    name = "databricks-metastore"

    source_addresses = [
      join(", ", azurerm_subnet.public.address_prefixes),
      join(", ", azurerm_subnet.private.address_prefixes),
    ]

    destination_addresses = local.metastore_ips
    destination_ports     = ["3306"]
    protocols = [
      "TCP",
    ]
  }

  rule {
    name = "databricks-eventhubs"

    source_addresses = [
      join(", ", azurerm_subnet.public.address_prefixes),
      join(", ", azurerm_subnet.private.address_prefixes),
    ]

    destination_addresses = local.eventhubs_ips
    destination_ports     = ["9093"]
    protocols = [
      "TCP",
    ]
  }

}


resource "azurerm_firewall_application_rule_collection" "adbfqdn" {
  name                = "adbcontrolplanefqdn"
  azure_firewall_name = azurerm_firewall.hubfw.name
  resource_group_name = azurerm_resource_group.this.name
  priority            = 200
  action              = "Allow"

  rule {
    name = "databricks-control-plane-services"

    source_addresses = [
      join(", ", azurerm_subnet.public.address_prefixes),
      join(", ", azurerm_subnet.private.address_prefixes),
    ]

    target_fqdns = var.firewallfqdn

    protocol {
      port = "443"
      type = "Https"
    }
  }

  rule {
    name = "databricks-dbfs"

    source_addresses = [
      join(", ", azurerm_subnet.public.address_prefixes),
      join(", ", azurerm_subnet.private.address_prefixes),
    ]

    target_fqdns = ["${local.dbfsname}.dfs.core.windows.net", "${local.dbfsname}.blob.core.windows.net"]

    protocol {
      port = "443"
      type = "Https"
    }
  }

  rule {
    name = "storage-accounts"

    source_addresses = [
      join(", ", azurerm_subnet.public.address_prefixes),
      join(", ", azurerm_subnet.private.address_prefixes),
    ]

    target_fqdns = ["${azurerm_storage_account.allowedstorage.name}.dfs.core.windows.net"]

    protocol {
      port = "443"
      type = "Https"
    }
  }

  dynamic "rule" {
    for_each = var.bypass_scc_relay ? [] : [1]
    content {
      name = "databricks-scc-relay"

      source_addresses = [
        join(", ", azurerm_subnet.public.address_prefixes),
        join(", ", azurerm_subnet.private.address_prefixes),
      ]

      target_fqdns = var.scc_relay

      protocol {
        port = "443"
        type = "Https"
      }
    }
  }
}

resource "azurerm_route_table" "adbroute" {
  //route all traffic from spoke vnet to hub vnet
  name                = "spoke-routetable"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags

  route {
    name                   = "to-firewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.hubfw.ip_configuration.0.private_ip_address // extract single item
  }

  dynamic "route" {
    for_each = var.bypass_scc_relay ? local.scc_relay_ips : []
    content {
      name           = "to-scc-${route.value}"
      address_prefix = "${route.value}/32"
      next_hop_type  = "Internet" // since scc is azure service IP, traffic will remain in azure backbone, not Internet
    }
  }

}

resource "azurerm_subnet_route_table_association" "publicudr" {
  subnet_id      = azurerm_subnet.public.id
  route_table_id = azurerm_route_table.adbroute.id
}

resource "azurerm_subnet_route_table_association" "privateudr" {
  subnet_id      = azurerm_subnet.private.id
  route_table_id = azurerm_route_table.adbroute.id
}
