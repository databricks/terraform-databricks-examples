# Create a Databricks MWS Network Connectivity Configuration
resource "databricks_mws_network_connectivity_config" "ncc" {
  # Use the Databricks provider configured for account-level operations
  provider = databricks.accounts
  
  # Name of the network connectivity configuration
  name     = "ncc-${azurerm_databricks_workspace.this.name}"
  
  # Region where the configuration will be created
  region   = var.azure_region
}

# Bind the network connectivity configuration to a Databricks workspace
resource "databricks_mws_ncc_binding" "ncc_binding" {
  # Use the Databricks provider configured for account-level operations
  provider                       = databricks.accounts
  
  # ID of the network connectivity configuration to bind
  network_connectivity_config_id = databricks_mws_network_connectivity_config.ncc.network_connectivity_config_id
  
  # ID of the workspace to bind the configuration to
  workspace_id                   =  azurerm_databricks_workspace.this.workspace_id
}

locals {
  all_storage_subnets = [for conf in databricks_mws_network_connectivity_config.ncc.egress_config :
    [for rule in conf.default_rules :
      [for se_rule in rule.azure_service_endpoint_rule :
        se_rule.subnets if contains(se_rule.target_services, "AZURE_BLOB_STORAGE")
      ]
    ]
  ]
  uniq_storage_subnets = distinct(flatten(local.all_storage_subnets))
}
