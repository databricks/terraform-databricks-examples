provider "databricks" {
  host               = "https://accounts.gcp.databricks.com"
  account_id         = var.databricks_account_id
}

provider "databricks" {
  alias              = "workspace"

  host               = module.gcp_with_data_exfiltration_protection.workspace_url
}

provider "google" {
}
