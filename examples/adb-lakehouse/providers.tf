provider "azurerm" {
  features {}
  skip_provider_registration = true
}

provider "databricks" {
  alias      = "account"
  host       = "https://accounts.azuredatabricks.net"
  account_id = "<account_id>"
}

provider "databricks" {
  alias = "workspace"
  host  = module.adb-lakehouse.workspace_url
}