
# Create an Azure Databricks Access Connector
resource "azurerm_databricks_access_connector" "ac" {
  
  # Name of the access connector
  name = "${var.name_prefix}-ac"
  
  # Name of the resource group where the access connector will reside
  resource_group_name = azurerm_resource_group.this.name
  
  # Location where the access connector will be created
  location            = var.azure_region

  # Configure the access connector to use a system-assigned identity
  identity {
    type = "SystemAssigned"
  }

  # Tags to apply to the access connector for organization and billing
  tags = var.tags
}

# Create an Azure Databricks Workspace
resource "azurerm_databricks_workspace" "this" {
  # Name of the Databricks workspace
  name                                  = "${var.name_prefix}-workspace"
  
  # Name of the resource group where the workspace will reside
  resource_group_name                   = azurerm_resource_group.this.name
  
  # Name of the managed resource group for the workspace
  managed_resource_group_name           = "${var.name_prefix}-mrg"
  
  # Location where the workspace will be created
  location                              = var.azure_region
  
  # SKU of the workspace (e.g., premium, standard)
  sku                                   = "premium"
  
  # Tags to apply to the workspace for organization and billing
  tags                                  = var.tags
  
  # Enable or disable public network access to the workspace
  public_network_access_enabled         = var.public_network_access_enabled
  
  # Require network security group rules for the workspace
  network_security_group_rules_required = var.network_security_group_rules_required
  
  # Enable customer-managed keys for encryption
  customer_managed_key_enabled          = true
  
  # Enable or disable default storage firewall for the workspace
  default_storage_firewall_enabled      = var.default_storage_firewall_enabled
  
  # ID of the access connector to use with the workspace
  access_connector_id                   =  azurerm_databricks_access_connector.ac.id
  
  # Custom parameters for the workspace configuration
  custom_parameters {
    # Disable public IP for the workspace
    no_public_ip                                         = true
    
    # ID of the virtual network where the workspace will be created
    virtual_network_id                                   = azurerm_virtual_network.this.id
    
    # Name of the private subnet for the workspace
    private_subnet_name                                  = azurerm_subnet.private.name
    
    # Name of the public subnet for the workspace
    public_subnet_name                                   = azurerm_subnet.public.name
    
    # ID of the public subnet's network security group association
    public_subnet_network_security_group_association_id  = azurerm_subnet_network_security_group_association.public.id
    
    # ID of the private subnet's network security group association
    private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.private.id
    
    # Name of the storage account for DBFS
    storage_account_name                                 = var.dbfs_storage_account
  }

}

# Retrieve the ID of the specified Databricks metastore
data "databricks_metastore" "this" {
  # Use the Databricks provider configured for account-level operations
  provider = databricks.accounts
  
  # Name of the metastore to retrieve
  name = var.databricks_metastore
}

# Assign the metastore to the Databricks workspace
resource "databricks_metastore_assignment" "this" {
  # Use the Databricks provider configured for account-level operations
  provider     = databricks.accounts
  
  # ID of the metastore to assign
  metastore_id = data.databricks_metastore.this.id
  
  # ID of the workspace to assign the metastore to
  workspace_id = azurerm_databricks_workspace.this.workspace_id
  
}

# Output the URL of the Databricks workspace
output "databricks_host" {
  value = "https://${azurerm_databricks_workspace.this.workspace_url}/"
}
