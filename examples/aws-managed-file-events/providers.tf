provider "aws" {
  region  = var.region
  profile = var.aws_profile
}

# Workspace-level Databricks provider
provider "databricks" {
  host  = var.databricks_host
  client_id     = var.databricks_client_id
  client_secret = var.databricks_client_secret
}
