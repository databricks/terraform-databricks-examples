module "adb-serverless-appgw-tls-transit" {
  source = "../../modules/adb-serverless-appgw-tls-transit"

  azure_subscription_id   = var.azure_subscription_id
  azure_region            = var.azure_region
  rg_name                 = var.rg_name
  databricks_host         = var.databricks_host
  databricks_account_id   = var.databricks_account_id
  databricks_workspace_id = var.databricks_workspace_id

  # Target TLS service (e.g. Kafka brokers) reachable from the transit VNet,
  # and the FQDNs serverless clients dial.
  backend_addresses       = var.backend_addresses
  serverless_domain_names = var.serverless_domain_names
  listener_port           = var.listener_port

  tags = var.tags
}
