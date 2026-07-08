resource "databricks_mws_customer_managed_keys" "managed_services" {
  count = var.cmek_managed_services_key_id != null ? 1 : 0

  account_id = var.databricks_account_id
  gcp_key_info {
    kms_key_id = var.cmek_managed_services_key_id
  }
  use_cases = ["MANAGED_SERVICES"]
}

resource "databricks_mws_customer_managed_keys" "storage" {
  count = var.cmek_storage_key_id != null ? 1 : 0

  account_id = var.databricks_account_id
  gcp_key_info {
    kms_key_id = var.cmek_storage_key_id
  }
  use_cases = ["STORAGE"]
}
