resource "databricks_mws_private_access_settings" "this" {
  count = local.emit_pas ? 1 : 0

  account_id                   = var.databricks_account_id
  private_access_settings_name = "${var.prefix}-pas-${var.suffix}"
  region                       = var.google_region
  public_access_enabled        = false
  private_access_level         = "ACCOUNT"
}
