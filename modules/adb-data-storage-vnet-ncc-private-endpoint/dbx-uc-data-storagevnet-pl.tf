// Create a private link subnet within the VNet
resource "azurerm_subnet" "plsubnet" {
  # Name of the subnet to create
  name                                      = "${var.name_prefix}-privatelink"
  
  # Name of the resource group where the subnet will reside
  resource_group_name                       = azurerm_resource_group.this.name
  
  # Name of the VNet where the subnet will be created
  virtual_network_name                      = azurerm_virtual_network.this.name
  
  # Address prefix for the subnet
  address_prefixes                          = [var.pl_subnets_cidr]
}

//private dsn zone for data-dfs
resource "azurerm_private_dns_zone" "dfs" {
  # Name of the private DNS zone to create
  name                = "privatelink.dfs.core.windows.net"
  
  # Name of the resource group where the DNS zone will reside
  resource_group_name = azurerm_resource_group.this.name
  
  # Tags to apply to the DNS zone for organization and billing
  tags                = var.tags
}

//private dsn zone for data-blob
resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.this.name
  tags                = var.tags
}

// Link the private DNS zone to the VNet
resource "azurerm_private_dns_zone_virtual_network_link" "dfsdnszonevnetlink" {
  # Name of the DNS zone link to create
  name                  = "dfsvnetconnection"
  
  # Name of the resource group where the link will reside
  resource_group_name   = azurerm_resource_group.this.name
  
  # Name of the private DNS zone to link
  private_dns_zone_name = azurerm_private_dns_zone.dfs.name
  
  # ID of the VNet to link to the DNS zone
  virtual_network_id    = azurerm_virtual_network.this.id// Connect to the spoke VNet
  
  # Tags to apply to the link for organization and billing
  tags                  = var.tags
}


// Link the private DNS zone to the VNet
resource "azurerm_private_dns_zone_virtual_network_link" "blobdnszonevnetlink" {
  # Name of the DNS zone link to create
  name                  = "blobvnetconnection"
  
  # Name of the resource group where the link will reside
  resource_group_name   = azurerm_resource_group.this.name
  
  # Name of the private DNS zone to link
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  
  # ID of the VNet to link to the DNS zone
  virtual_network_id    = azurerm_virtual_network.this.id // Connect to the spoke VNet
  
  # Tags to apply to the link for organization and billing
  tags                  = var.tags
}

// Create a private endpoint for the workspace to access the data storage (catalog external location)
resource "azurerm_private_endpoint" "data_dfs" {
  # Name of the private endpoint to create
  name                = "datapvtendpoint"
  
  # Location where the private endpoint will be created
  location            = var.azure_region
  
  # Name of the resource group where the private endpoint will reside
  resource_group_name = azurerm_resource_group.this.name
  
  # ID of the subnet where the private endpoint will be created
  subnet_id           = azurerm_subnet.plsubnet.id
  
  # Tags to apply to the private endpoint for organization and billing
  tags                = var.tags
  
  # Configure the private service connection
  private_service_connection {
    # Name of the private connection
    name                           = "ple-${var.name_prefix}-data"
    
    # ID of the storage account resource to connect to
    private_connection_resource_id = azurerm_storage_account.this.id
    
    # Use automatic connection approval
    is_manual_connection           = false
    
    # Subresource names to connect to (e.g., dfs for Data Lake Storage)
    subresource_names              = ["dfs"]
  }
  
  # Configure the private DNS zone group
  private_dns_zone_group {
    # Name of the DNS zone group
    name                 = "private-dns-zone-data-dfs"
    
    # IDs of the private DNS zones to include in the group
    private_dns_zone_ids = [azurerm_private_dns_zone.dfs.id]
  }
}


// Create a private endpoint for the workspace to access the data storage (catalog external location)
resource "azurerm_private_endpoint" "data_blob" {
  # Name of the private endpoint to create
  name                = "datapvtendpointblob"
  
  # Location where the private endpoint will be created
  location            = var.azure_region
  
  # Name of the resource group where the private endpoint will reside
  resource_group_name = azurerm_resource_group.this.name
  
  # ID of the subnet where the private endpoint will be created
  subnet_id           = azurerm_subnet.plsubnet.id
  
  # Tags to apply to the private endpoint for organization and billing
  tags                = var.tags
  
  # Configure the private service connection
  private_service_connection {
    # Name of the private connection
    name                           = "ple-${var.name_prefix}-data-blob"
    
    # ID of the storage account resource to connect to
    private_connection_resource_id = azurerm_storage_account.this.id
    
    # Use automatic connection approval
    is_manual_connection           = false
    
    # Subresource names to connect to (e.g., dfs for Data Lake Storage)
    subresource_names              = ["blob"]
  }
  
  # Configure the private DNS zone group
  private_dns_zone_group {
    # Name of the DNS zone group
    name                 = "private-dns-zone-data-blob"
    
    # IDs of the private DNS zones to include in the group
    private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]
  }
}
