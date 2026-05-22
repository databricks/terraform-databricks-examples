provider "databricks" {
  host       = "https://accounts.gcp.databricks.com"
  account_id = var.databricks_account_id
}

provider "databricks" {
  alias = "workspace"

  host = module.workspace.workspace_url
}

provider "google" {
}
