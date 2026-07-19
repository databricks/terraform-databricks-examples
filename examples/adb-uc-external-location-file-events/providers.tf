provider "azurerm" {
  features {}
}

# Authenticate to an existing UC-enabled workspace.
# Prefer `databricks auth login --host <workspace-url>` and omit explicit credentials,
# or set host / token / Azure auth via environment variables.
provider "databricks" {
  host = var.databricks_host
}
