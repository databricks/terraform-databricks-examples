#!/bin/bash

# Load JSON file into variable
json=$(cat workspaces_to_monitor.json)

# set the name of the module's source
module_source="../../modules/adb-overwatch-ws-to-monitor"
modules_list=(module.adb-overwatch-mws-config)

# Loop through JSON objects
for row in $(echo "${json}" | jq -r '.[] | @base64'); do
    # Decode JSON object
    _jq() {
        echo "${row}" | base64 --decode | jq -r "${1}"
    }

    # Generate Terraform Databricks provider configuration
    workspace_name=$(_jq '.workspace_name')
    host=$(_jq '.host')

    echo -e "provider \"databricks\" {
  alias = \"$workspace_name\"
  host = \"$host\"
}\n" >> providers_ws_to_monitor.tf

    # Set the name of the module dynamically
    module_name="adb-overwatch-monitor-$workspace_name"

    # Set the name of the provider and the Databricks value you want to use
    provider_name="databricks"
    databricks_provider_value="databricks.$workspace_name"

    # Generate the JSON block
    json_block=$(cat <<EOF
module "$module_name" {
  source = "$module_source"

  providers = {
    $provider_name = $databricks_provider_value
  }

  adb_ws_name = "$workspace_name"
  random_string                 = random_string.strapp.result
  tenant_id                     = var.tenant_id
  rg_name                       = var.rg_name
  overwatch_spn_app_id          = var.overwatch_spn_app_id
  ehn_name                      = module.adb-overwatch-regional-config.ehn_name
  ehn_auth_rule_name            = module.adb-overwatch-regional-config.ehn_ar_name
  logs_sa_name                  = module.adb-overwatch-regional-config.logs_sa_name
  akv_name                      = module.adb-overwatch-regional-config.akv_name
  databricks_secret_scope_name  = var.databricks_secret_scope_name
  etl_storage_prefix = module.adb-overwatch-mws-config.etl_storage_prefix
  active                        = var.active
  api_waiting_time              = var.api_waiting_time
  automated_dbu_price           = var.automated_dbu_price
  enable_unsafe_SSL             = var.enable_unsafe_SSL
  error_batch_size              = var.error_batch_size
  excluded_scopes               = var.excluded_scopes
  interactive_dbu_price         = var.interactive_dbu_price
  jobs_light_dbu_price          = var.jobs_light_dbu_price
  max_days                      = var.max_days
  proxy_host                    = var.proxy_host
  proxy_password_key            = var.proxy_password_key
  proxy_password_scope          = var.proxy_password_scope
  proxy_port                    = var.proxy_port
  proxy_user_name               = var.proxy_user_name
  sql_compute_dbu_price         = var.sql_compute_dbu_price
  success_batch_size            = var.success_batch_size
  thread_pool_size              = var.thread_pool_size
  auditlog_prefix_source_path    = var.auditlog_prefix_source_path

  depends_on = [module.adb-overwatch-regional-config]
}
EOF
)

    echo -e "$json_block\n" >> main_ws_to_monitor.tf

    element="module.adb-overwatch-monitor-$workspace_name"
    modules_list+=("$element")

done

echo "workspace_name,workspace_id,workspace_url,api_url,cloud,primordial_date,etl_storage_prefix,etl_database_name,consumer_database_name,secret_scope,secret_key_dbpat,auditlogprefix_source_path,eh_name,eh_scope_key,interactive_dbu_price,automated_dbu_price,sql_compute_dbu_price,jobs_light_dbu_price,max_days,excluded_scopes,active,proxy_host,proxy_port,proxy_user_name,proxy_password_scope,proxy_password_key,success_batch_size,error_batch_size,enable_unsafe_SSL,thread_pool_size,api_waiting_time" > overwatch_deployment_config.csv

dependencies="["$(IFS=, ; echo "${modules_list[*]}")"]"

echo -e "resource \"databricks_dbfs_file\" \"overwatch_deployment_config\" {
  provider = databricks.adb-ow-main-ws

  source = \"\${path.module}/overwatch_deployment_config.csv\"
  path   = \"/mnt/\${module.adb-overwatch-mws-config.databricks_mount_db_name}/config/overwatch_deployment_config.csv\"
  depends_on = $dependencies
}" >> main_ws_to_monitor.tf