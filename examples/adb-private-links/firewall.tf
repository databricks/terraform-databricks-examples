resource "azurerm_public_ip" "fwpublicip" {
  name                = "hubfirewallpublicip"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "hubfw" {
  name                = "hubfirewall"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.hubfw.id
    public_ip_address_id = azurerm_public_ip.fwpublicip.id
  }
}


resource "azurerm_firewall_network_rule_collection" "adbfnetwork" {
  name                = "adbcontrolplanenetwork"
  azure_firewall_name = azurerm_firewall.hubfw.name
  resource_group_name = azurerm_resource_group.this.name
  priority            = 200
  action              = "Allow"

  rule {
    name = "databricks-metastore"

    source_addresses = [
      join(", ", azurerm_subnet.public.address_prefixes),
      join(", ", azurerm_subnet.private.address_prefixes),
    ]

    destination_ports = [
      "3306",
    ]

    destination_addresses = [
      var.metastoreip,
    ]

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
}

resource "azurerm_route_table" "adbroute" {
  //route all traffic from spoke vnet to hub vnet
  name                = "spoke-routetable"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  route {
    name                   = "to-firewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.hubfw.ip_configuration.0.private_ip_address // extract single item
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
