# Create an Azure Resource Group
resource "azurerm_resource_group" "this" {
  # Name of the resource group
  name     = var.rg_name
  
  # Location where the resource group will be created
  location = var.azure_region
  
  # Tags to apply to the resource group for organization and billing
  tags     = var.tags
}

# Create a Virtual Network (VNet) within the resource group
resource "azurerm_virtual_network" "this" {
  # Name of the VNet
  name                = "${var.name_prefix}-vnet"
  
  # Location where the VNet will be created
  location            = var.azure_region
  
  # Name of the resource group where the VNet will reside
  resource_group_name = azurerm_resource_group.this.name
  
  # Address space for the VNet
  address_space       = [var.cidr_block]
  
  # Tags to apply to the VNet for organization and billing
  tags                = var.tags
  
}

# Create a Network Security Group (NSG) for controlling traffic
resource "azurerm_network_security_group" "this" {
  # Name of the NSG
  name                = "${var.name_prefix}-nsg"
  
  # Location where the NSG will be created
  location            = var.azure_region
  
  # Name of the resource group where the NSG will reside
  resource_group_name = azurerm_resource_group.this.name
  
  # Tags to apply to the NSG for organization and billing
  tags                = var.tags
  
}

# Create a public subnet within the VNet
resource "azurerm_subnet" "public" {
  # Name of the public subnet
  name                 = "${var.name_prefix}-public"
  
  # Name of the resource group where the subnet will reside
  resource_group_name  = azurerm_resource_group.this.name
  
  # Name of the VNet where the subnet will be created
  virtual_network_name = azurerm_virtual_network.this.name
  
  # Address prefix for the public subnet
  address_prefixes     = [var.public_subnets_cidr]
  
  # Delegate subnet management to Databricks for workspace creation
  delegation {
    name = "databricks"
    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"]
    }
  }
  
  # Service endpoints to enable for the subnet
  service_endpoints = var.subnet_service_endpoints
}

# Associate the public subnet with the NSG
resource "azurerm_subnet_network_security_group_association" "public" {
  # ID of the public subnet
  subnet_id                 = azurerm_subnet.public.id
  
  # ID of the NSG to associate with the subnet
  network_security_group_id = azurerm_network_security_group.this.id
  
}

# Create a private subnet within the VNet
resource "azurerm_subnet" "private" {
  # Name of the private subnet
  name                 = "${var.name_prefix}-private"
  
  # Name of the resource group where the subnet will reside
  resource_group_name  = azurerm_resource_group.this.name
  
  # Name of the VNet where the subnet will be created
  virtual_network_name = azurerm_virtual_network.this.name
  
  # Address prefix for the private subnet
  address_prefixes     = [var.private_subnets_cidr]
  
  # Delegate subnet management to Databricks for workspace creation
  delegation {
    name = "databricks"
    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"]
    }
  }
  
  # Service endpoints to enable for the subnet
  service_endpoints = var.subnet_service_endpoints
}

# Associate the private subnet with the NSG
resource "azurerm_subnet_network_security_group_association" "private" {
  # ID of the private subnet
  subnet_id                 = azurerm_subnet.private.id
  
  # ID of the NSG to associate with the subnet
  network_security_group_id = azurerm_network_security_group.this.id
  
}
