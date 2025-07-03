// Create a resource group for the storage account and associated resources
resource "azurerm_resource_group" "storage_rg" {
  # Name of the resource group to create
  name     = var.data_storage_account_rg
  
  # Location where the resource group will be created
  location = var.azure_region
  
  # Tags to apply to the resource group for organization and billing
  tags     = var.tags
}

// Create a storage account for ADLS with hierarchical namespace enabled
resource "azurerm_storage_account" "this" {
  # Replication type for the storage account (e.g., LRS for locally redundant storage)
  account_replication_type = "LRS"
  
  # Tier of the storage account (e.g., Standard)
  account_tier             = "Standard"
  
  # Location where the storage account will be created
  location                 = var.azure_region
  
  # Name of the storage account to create
  name                     = var.data_storage_account
  
  # Name of the resource group where the storage account will reside
  resource_group_name      = azurerm_resource_group.storage_rg.name
  
  # Enable hierarchical namespace for ADLS
  is_hns_enabled           = true
 
  # Tags to apply to the storage account for organization and billing
  tags                     = var.tags
  
}

resource "azurerm_storage_account_network_rules" "this" {
  storage_account_id = azurerm_storage_account.this.id

  default_action             = "Deny"
  virtual_network_subnet_ids = concat(
      [ azurerm_subnet.public.id ],
      local.uniq_storage_subnets
    )
}

// Create a container within the storage account
resource "azurerm_storage_container" "this" {
  # Name of the container to create
  name                  = "container"
  
  # ID of the storage account where the container will be created
  storage_account_id    = azurerm_storage_account.this.id
  
  # Access type for the container (e.g., container-level access)
  container_access_type = "private"

}

// Create a user-assigned identity for accessing the storage account
resource "azurerm_user_assigned_identity" "this" {
  # Location where the identity will be created
  location            = var.azure_region
  
  # Name of the user-assigned identity to create
  name                = "${var.data_storage_account}-user-identity"
  
  # Name of the resource group where the identity will reside
  resource_group_name = azurerm_resource_group.storage_rg.name
  
  # Tags to apply to the identity for organization and billing
  tags                = var.tags

}

// Assign the Storage Blob Data Contributor role to the user-assigned identity for the storage account
resource "azurerm_role_assignment" "this" {
  # Scope of the role assignment (e.g., the storage account ID)
  scope                = azurerm_storage_account.this.id
  
  # Name of the role definition to assign (e.g., Storage Blob Data Contributor)
  role_definition_name = "Storage Blob Data Contributor"
  
  # Principal ID of the user-assigned identity to assign the role to
  principal_id         = azurerm_user_assigned_identity.this.principal_id
  
}

// Create a Databricks access connector using the user-assigned identity
resource "azurerm_databricks_access_connector" "this" {
  # Location where the access connector will be created
  location            = var.azure_region
  
  # Name of the access connector to create
  name                = "${var.data_storage_account}-access-connector"
  
  # Name of the resource group where the access connector will reside
  resource_group_name = azurerm_resource_group.storage_rg.name
  
  # Tags to apply to the access connector for organization and billing
  tags                = var.tags
  
  # Configure the access connector to use a user-assigned identity
  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.this.id]
  }
}
