provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id
}

// Account-level provider: NCCs, NCC bindings and private network gateways
// are account objects. With auth_type "azure-cli" the provider uses your
// `az login` session. For OAuth machine-to-machine auth, set auth_type to
// "oauth-m2m" and export DATABRICKS_CLIENT_ID and DATABRICKS_CLIENT_SECRET.
provider "databricks" {
  host            = "https://accounts.azuredatabricks.net"
  account_id      = var.databricks_account_id
  auth_type       = var.databricks_auth_type
  azure_tenant_id = var.azure_tenant_id
}
