//private link for root storage
data "azurerm_storage_account" "dbfs_storage_account" {
  name                = var.dbfs_storage_account
  resource_group_name = azurerm_databricks_workspace.this.managed_resource_group_name
}


// Add a private endpoint rule for the NCC to access the storage account
resource "databricks_mws_ncc_private_endpoint_rule" "dbfs_dfs" {
  # Use the Databricks provider configured for account-level operations
  provider = databricks.accounts

  # ID of the network connectivity configuration to add the rule to
  #network_connectivity_config_id = jsondecode(data.restapi_object.ncc.api_response).network_connectivity_config_id
  network_connectivity_config_id = databricks_mws_network_connectivity_config.ncc.network_connectivity_config_id

  # ID of the storage account resource
  resource_id = data.azurerm_storage_account.dbfs_storage_account.id

  # Group ID for the private endpoint rule (e.g., dfs for Data Lake Storage)
  group_id = "dfs"
}

// Add a private endpoint rule for the NCC to access the storage account
resource "databricks_mws_ncc_private_endpoint_rule" "dbfs_blob" {
  # Use the Databricks provider configured for account-level operations
  provider = databricks.accounts

  # ID of the network connectivity configuration to add the rule to
  network_connectivity_config_id = databricks_mws_network_connectivity_config.ncc.network_connectivity_config_id

  # ID of the storage account resource
  resource_id = data.azurerm_storage_account.dbfs_storage_account.id

  # Group ID for the private endpoint rule (e.g., dfs for Data Lake Storage)
  group_id = "blob"
}

// Retrieve the list of private endpoint connections for the DBFS storage account
data "azapi_resource_list" "list_storage_private_endpoint_connection_dbfs" {
  # Type of resource to retrieve (e.g., private endpoint connections for storage accounts)
  type = "Microsoft.Storage/storageAccounts/privateEndpointConnections@2022-09-01"

  # Parent ID of the storage account resource
  parent_id = "/subscriptions/${var.azure_subscription_id}/resourceGroups/${azurerm_databricks_workspace.this.managed_resource_group_name}/providers/Microsoft.Storage/storageAccounts/${var.dbfs_storage_account}"

  # Export all response values
  response_export_values = ["*"]

  # Ensure the data depends on the private endpoint rule being created first
  depends_on = [databricks_mws_ncc_private_endpoint_rule.storage_dfs, databricks_mws_ncc_private_endpoint_rule.storage_blob]
}

// Approve the private endpoint connection for the DBFS storage account (dfs)
resource "azapi_update_resource" "approve_storage_private_endpoint_connection_dbfs_dfs" {
  # Type of resource to update (e.g., private endpoint connections for storage accounts)
  type = "Microsoft.Storage/storageAccounts/privateEndpointConnections@2022-09-01"

  # Name of the private endpoint connection to approve
  name = [
    for i in data.azapi_resource_list.list_storage_private_endpoint_connection_dbfs.output.value
    : i.name if endswith(i.properties.privateEndpoint.id, databricks_mws_ncc_private_endpoint_rule.dbfs_dfs.endpoint_name)
  ][0]

  # Parent ID of the storage account resource
  parent_id = data.azurerm_storage_account.dbfs_storage_account.id

  # Body of the update request
  body = {
    properties = {
      # Update the private link service connection state to approved
      privateLinkServiceConnectionState = {
        description = "Auto Approved via Terraform"
        status      = "Approved"
      }
    }
  }
}

// Approve the private endpoint connection for the DBFS storage account (blob)
resource "azapi_update_resource" "approve_storage_private_endpoint_connection_dbfs_blob" {
  # Type of resource to update (e.g., private endpoint connections for storage accounts)
  type = "Microsoft.Storage/storageAccounts/privateEndpointConnections@2022-09-01"

  # Name of the private endpoint connection to approve
  name = [
    for i in data.azapi_resource_list.list_storage_private_endpoint_connection_dbfs.output.value
    : i.name if endswith(i.properties.privateEndpoint.id, databricks_mws_ncc_private_endpoint_rule.dbfs_blob.endpoint_name)
  ][0]

  # Parent ID of the storage account resource
  parent_id = data.azurerm_storage_account.dbfs_storage_account.id

  # Body of the update request
  body = {
    properties = {
      # Update the private link service connection state to approved
      privateLinkServiceConnectionState = {
        description = "Auto Approved via Terraform"
        status      = "Approved"
      }
    }
  }
}
