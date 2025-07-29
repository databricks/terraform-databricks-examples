// Create a private endpoint for the workspace to access the data storage (catalog external location)
resource "azurerm_private_endpoint" "dbfs_dfs" {
  # Name of the private endpoint to create
  name = "dbfspvtendpoint"

  # Location where the private endpoint will be created
  location = var.azure_region

  # Name of the resource group where the private endpoint will reside
  resource_group_name = azurerm_resource_group.this.name

  # ID of the subnet where the private endpoint will be created
  subnet_id = azurerm_subnet.plsubnet.id

  # Tags to apply to the private endpoint for organization and billing
  tags = var.tags

  # Configure the private service connection
  private_service_connection {
    # Name of the private connection
    name = "ple-${var.name_prefix}-dbfs"

    # ID of the storage account resource to connect to
    private_connection_resource_id = data.azurerm_storage_account.dbfs_storage_account.id

    # Use automatic connection approval
    is_manual_connection = false

    # Subresource names to connect to (e.g., dfs for Data Lake Storage)
    subresource_names = ["dfs"]
  }

  # Configure the private DNS zone group
  private_dns_zone_group {
    # Name of the DNS zone group
    name = "private-dns-zone-dbfs-dfs"

    # IDs of the private DNS zones to include in the group
    private_dns_zone_ids = [azurerm_private_dns_zone.dfs.id]
  }
}


// Create a private endpoint for the workspace to access the data storage (catalog external location)
resource "azurerm_private_endpoint" "dbfs_blob" {
  # Name of the private endpoint to create
  name = "dbfspvtendpointblob"

  # Location where the private endpoint will be created
  location = var.azure_region

  # Name of the resource group where the private endpoint will reside
  resource_group_name = azurerm_resource_group.this.name

  # ID of the subnet where the private endpoint will be created
  subnet_id = azurerm_subnet.plsubnet.id

  # Tags to apply to the private endpoint for organization and billing
  tags = var.tags

  # Configure the private service connection
  private_service_connection {
    # Name of the private connection
    name = "ple-${var.name_prefix}-dbfs-blob"

    # ID of the storage account resource to connect to
    private_connection_resource_id = data.azurerm_storage_account.dbfs_storage_account.id

    # Use automatic connection approval
    is_manual_connection = false

    # Subresource names to connect to (e.g., dfs for Data Lake Storage)
    subresource_names = ["blob"]
  }

  # Configure the private DNS zone group
  private_dns_zone_group {
    # Name of the DNS zone group
    name = "private-dns-zone-dadbfsta-blob"

    # IDs of the private DNS zones to include in the group
    private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]
  }
}

