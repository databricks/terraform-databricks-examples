#####################################################
# Local Values and Random String Resource
#####################################################

# ---------------------------------------------------
# Local Value: Extract Workspace DNS ID
# ---------------------------------------------------
locals {
  # Extracts a numeric identifier from the Databricks workspace URL.
  # The regex pattern "[0-9]+\.[0-9]+" matches the first occurrence of two groups of digits separated by a dot (e.g., "1234567890123456.1234").
  # This value is typically used to generate unique DNS names for the workspace.
  workspace_dns_id = regex("[0-9]+\\.[0-9]+", databricks_mws_workspaces.databricks_workspace.workspace_url)
}

# ---------------------------------------------------
# Random String Resource: Suffix Generator
# ---------------------------------------------------
resource "random_string" "suffix" {
  special = false
  upper   = false
  length  = 6
}
