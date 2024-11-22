provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
}

provider "databricks" {
  alias      = "account"
  host       = "https://accounts.azuredatabricks.net"
  account_id = var.account_id
}

provider "databricks" {
  alias = "workspace"
  host  = module.adb-lakehouse.workspace_url
}
