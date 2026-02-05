provider "aws" {
  region  = var.region
  profile = var.aws_profile
}

# Workspace-level Databricks provider
provider "databricks" {
  host  = var.databricks_host
  token = var.databricks_pat_token
}
