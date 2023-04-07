resource "random_string" "strapp" {
  length  = 5
  lower = true
  upper = false
  special = false
}

module "adb-overwatch" {
  source = "../../modules/adb-overwatch"

  eventhub_name1             = "${var.eventhub_name}1"
  eventhub_name2             = "${var.eventhub_name}2"
  overwatch_spn_app_id       = var.overwatch_spn_app_id
  random_string              = random_string.strapp.result
  tenant_id                  = var.tenant_id
  adb_ws1                    = var.adb_ws1
  adb_ws2                    = var.adb_ws2
  rg_name                    = var.rg_name
  overwatch_spn_secret       = var.overwatch_spn_secret
}