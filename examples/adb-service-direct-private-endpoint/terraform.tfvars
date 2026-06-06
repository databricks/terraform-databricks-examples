azure_subscription_id = "00000000-0000-0000-0000-000000000000"
azure_region          = "australiaeast"
rg_name               = "rg-service-direct-pe"

databricks_host       = "https://accounts.azuredatabricks.net"
databricks_account_id = "00000000-0000-0000-0000-000000000000"

# Existing subnet for the private endpoint (PE network policies disabled).
private_endpoint_subnet_id = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/virtualNetworks/<vnet>/subnets/<pe-subnet>"

# Databricks per-region PLS resource ID for performance-intensive services.
# Pull the current value from the MS Learn region table:
# https://learn.microsoft.com/en-us/azure/databricks/resources/ip-domain-region#service-direct-resource-ids
databricks_pls_resource_id = "/subscriptions/<databricks-sub>/resourceGroups/<rg>/providers/Microsoft.Network/privateLinkServices/<pls>"

# Create privatelink.azuredatabricks.net here and link the VNet hosting the PE.
# Set false (and pre-create the zone) if the workspace already uses inbound PL.
create_private_dns_zone = true
vnet_ids_to_link        = ["/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/virtualNetworks/<vnet>"]

tags = {
  Environment = "dev"
  Workload    = "service-direct-privatelink"
}
