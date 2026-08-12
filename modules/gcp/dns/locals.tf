locals {
  # Regex extracts the workspace DNS id (numeric.numeric) from the URL.
  workspace_dns_id = regex("[0-9]+\\.[0-9]+", var.workspace_url)
}
