azure_subscription_id = "00000000-0000-0000-0000-000000000000"
azure_region          = "australiaeast"
rg_name               = "rg-appgw-tls-transit"

appgw_name     = "appgw-serverless-transit"
appgw_capacity = 2

databricks_host         = "https://accounts.azuredatabricks.net"
databricks_account_id   = "00000000-0000-0000-0000-000000000000"
databricks_workspace_id = "1234567890123456"

# Use either backend_addresses (IP addresses) or backend_fqdns (DNS names).
# The target must be reachable from the transit VNet.
backend_addresses = ["10.230.3.10"]
backend_fqdns     = []

# Include the bootstrap name and any names returned by Kafka broker metadata.
serverless_domain_names = [
  "lkc-xxxxx.<network-id>.australiaeast.azure.confluent.cloud",
  "*.<network-id>.australiaeast.azure.confluent.cloud",
]

listener_port = 9092
backend_port  = null

# Leave false to approve the App Gateway private endpoint manually in Azure.
auto_approve_private_endpoint = false

tags = {
  Environment = "dev"
  Workload    = "serverless-tls-privatelink"
}
