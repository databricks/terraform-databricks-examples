module "adb-service-direct-private-endpoint" {
  source = "../../modules/adb-service-direct-private-endpoint"

  azure_subscription_id      = var.azure_subscription_id
  azure_region               = var.azure_region
  rg_name                    = var.rg_name
  databricks_host            = var.databricks_host
  databricks_account_id      = var.databricks_account_id
  private_endpoint_subnet_id = var.private_endpoint_subnet_id
  databricks_pls_resource_id = var.databricks_pls_resource_id

  create_private_dns_zone = var.create_private_dns_zone
  vnet_ids_to_link        = var.vnet_ids_to_link

  tags = var.tags
}
