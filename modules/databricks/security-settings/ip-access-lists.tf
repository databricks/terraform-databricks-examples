resource "databricks_workspace_conf" "enable_ip_access_lists" {
  count = length(var.ip_access_lists) > 0 ? 1 : 0

  custom_config = {
    "enableIpAccessLists" = "true"
  }
}

resource "databricks_ip_access_list" "this" {
  for_each = { for l in var.ip_access_lists : l.label => l }

  label        = each.value.label
  list_type    = each.value.list_type
  ip_addresses = each.value.ip_addresses

  depends_on = [databricks_workspace_conf.enable_ip_access_lists]
}
