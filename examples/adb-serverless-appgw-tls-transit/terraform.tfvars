azure_subscription_id = "00000000-0000-0000-0000-000000000000"
azure_region          = "australiaeast"
rg_name               = "rg-appgw-tls-transit"

databricks_host         = "https://accounts.azuredatabricks.net"
databricks_account_id   = "00000000-0000-0000-0000-000000000000"
databricks_workspace_id = "1234567890123456"

# Target TLS service (e.g. Kafka brokers) reachable from the transit VNet.
backend_addresses = ["10.230.3.10"]

# FQDNs serverless clients dial. For Confluent Cloud this is the cluster
# bootstrap FQDN + a wildcard for per-broker re-resolution. Max 10.
serverless_domain_names = [
  "lkc-xxxxx.<network-id>.australiaeast.azure.confluent.cloud",
  "*.<network-id>.australiaeast.azure.confluent.cloud",
]

listener_port = 9092

tags = {
  Environment = "dev"
  Workload    = "serverless-kafka-privatelink"
}
