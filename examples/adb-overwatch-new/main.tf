resource "random_string" "strapp" {
  length  = 5
  lower = true
  upper = false
  special = false
}

locals {
  // the workspace that Overwatch will monitor
  // ws_name = params
  adb_ws1_name = "adb-dev-ws"
}

module "adb-overwatch-regional-config" {
  source = "../../modules/adb-overwatch-regional-config"

  random_string         = random_string.strapp.result
  rg_name               = var.rg_name
  overwatch_spn_app_id  = var.overwatch_spn_app_id
  ehn_name              = var.ehn_name
  logs_sa_name          = var.logs_sa_name
  key_vault_prefix      = var.key_vault_prefix
  object_id             = var.object_id
  overwatch_spn_secret  = var.overwatch_spn_secret
}

/*module "adb-overwatch-monitor-ws-1" {
  source = "../../modules/adb-overwatch-ws-to-monitor"

  // update per workspace
  providers = {
    databricks = databricks.adb-ws-1
  }

  adb_ws_name = local.adb_ws1_name

  // do not depend on the workspace
  random_string                 = random_string.strapp.result
  tenant_id                     = var.tenant_id
  rg_name                       = var.rg_name
  object_id                     = var.object_id
  overwatch_spn_app_id          = var.overwatch_spn_app_id
  overwatch_spn_secret          = var.overwatch_spn_secret
  ehn_name                      = module.adb-overwatch-regional-config.ehn_name
  ehn_auth_rule_name            = module.adb-overwatch-regional-config.ehn_ar_name
  logs_sa_name                  = module.adb-overwatch-regional-config.logs_sa_name
  akv_name                      = module.adb-overwatch-regional-config.akv_name
  databricks_secret_scope_name  = var.databricks_secret_scope_name
}*/

module "adb-overwatch-main-ws" {
  source = "../../modules/adb-overwatch-main-ws"

  subscription_id = var.subscription_id
  rg_name = var.rg_name
  use_existing_ws = var.use_existing_overwatch_ws
  overwatch_ws_name = var.overwatch_ws_name
}


module "adb-overwatch-mws-config" {
  source = "../../modules/adb-overwatch-mws-config"
  providers = {
    databricks = databricks.adb-ow-main-ws
  }

  tenant_id                        = var.tenant_id
  rg_name                          = var.rg_name
  overwatch_spn_app_id             = var.overwatch_spn_app_id
  overwatch_ws_name                = var.overwatch_ws_name
  akv_name                         = module.adb-overwatch-regional-config.akv_name
  databricks_secret_scope_name     = var.databricks_secret_scope_name
  latest_dbr_lts = module.adb-overwatch-main-ws.latest_lts
  random_string                 = random_string.strapp.result
  ow_sa_name                       = var.ow_sa_name

  depends_on = [module.adb-overwatch-main-ws, module.adb-overwatch-regional-config]
}


/*
module "adb-overwatch-analysis" {
  source = "../../modules/adb-overwatch-analysis"
  providers = {
    databricks = databricks.adb-ow-main-ws
  }

  rg_name = var.rg_name
  overwatch_ws_name = var.overwatch_ws_name

  depends_on = [module.adb-overwatch-main-ws]
}*/
