module "adb-serverless-appgw-tls-transit" {
  source = "../../modules/adb-serverless-appgw-tls-transit"

  providers = {
    azurerm    = azurerm
    azapi      = azapi
    databricks = databricks.accounts
    null       = null
    time       = time
  }

  azure_subscription_id   = var.azure_subscription_id
  azure_region            = var.azure_region
  rg_name                 = var.rg_name
  appgw_name              = var.appgw_name
  appgw_capacity          = var.appgw_capacity
  databricks_host         = var.databricks_host
  databricks_account_id   = var.databricks_account_id
  databricks_workspace_id = var.databricks_workspace_id

  backend_addresses             = var.backend_addresses
  backend_fqdns                 = var.backend_fqdns
  listener_port                 = var.listener_port
  backend_port                  = var.backend_port
  serverless_domain_names       = var.serverless_domain_names
  auto_approve_private_endpoint = var.auto_approve_private_endpoint

  tags = var.tags
}
