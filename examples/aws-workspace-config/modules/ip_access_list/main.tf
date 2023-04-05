terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
      #configuration_aliases = [databricks.ws1, databricks.ws2]
    }
  }
}

resource "databricks_workspace_conf" "this" {
  custom_config = {
    "enableIpAccessLists" = true
  }
}

resource "databricks_ip_access_list" "allow-list" {
  label        = var.allow_list_label
  list_type    = "ALLOW"
  ip_addresses = var.allow_list
  depends_on   = [databricks_workspace_conf.this]
}

resource "databricks_ip_access_list" "block-list" {
  label        = var.deny_list_label
  list_type    = "BLOCK"
  ip_addresses = var.block_list
  depends_on   = [databricks_workspace_conf.this]
}
