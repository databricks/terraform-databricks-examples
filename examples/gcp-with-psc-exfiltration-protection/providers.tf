provider "databricks" {
  host       = "https://accounts.gcp.databricks.com"
  account_id = var.databricks_account_id
}

provider "google" {
}
