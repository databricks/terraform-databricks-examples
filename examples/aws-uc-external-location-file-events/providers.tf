provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

# Authenticate to an existing UC-enabled workspace whose assigned metastore is the
# one you want these objects in. Prefer `databricks auth login --host <workspace-url>`
# (a CLI profile) or environment variables over inline credentials.
provider "databricks" {
  profile = var.databricks_profile
}
