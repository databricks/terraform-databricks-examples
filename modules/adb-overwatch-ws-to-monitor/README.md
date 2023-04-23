# adb-overwatch-ws-to-monitor

This module deploys the required resources for a given Databricks workspace to be monitored by Overwatch :
- Databricks PAT that will be used by Overwatch jobs
- Eventhub topic with its authorization rule
- Diagnostics settings
- AKV secrets to store the Databricks PAT, and the Eventhub primary connection string created above 
- AKV-backed Databricks secret scope
- Container for the cluster logs in the existing log storage account
- Databricks mount to the container created above
- CSV file with all required parameters using [Overwatch deployment template](./overwatch_deployment_template.txt)


> **Note**  
> For more details on the column description, please refer to [Overwatch Deployment Configuration](https://databrickslabs.github.io/overwatch/deployoverwatch/configureoverwatch/configuration/)


## Inputs

| Name           | Description                                                                                                     | Type   | Default | Required |
|----------------|-----------------------------------------------------------------------------------------------------------------|--------|---------|----------|
|`adb_ws_name`| The name of an existing Databricks workspace that Overwatch will monitor                                        | string || yes     |
|`rg_name`| Resource group name                                                                                             | string || yes     |
|`ehn_name`| Eventhub namespace name                                                                                         | string || yes     |
|`tenant_id`| Azure tenant ID                                                                                                 | string || yes     |
|`overwatch_spn_app_id`| Azure SPN used to create Databricks mounts                                                                      | string || yes     |
|`ehn_auth_rule_name`| Eventhub namespace authorization rule name                                                                      | string || yes     |
|`logs_sa_name`| Logs storage account name                                                                                       | string || yes     |
|`random_string`| Random string used as a suffix for the resources names                                                          | string || yes     |
|`akv_name`| Azure Key-Vault name                                                                                            | string || yes     |
|`databricks_secret_scope_name`| Databricks secret scope name (backed by Azure Key-Vault)                                                        | string || yes     |
|`etl_storage_prefix`| Overwatch ETL storage prefix, which represents a mount point to the ETL storage account                         | string || yes     |
|`interactive_dbu_price`| Contract price for interactive DBUs                                                                             | number || yes     |
|`automated_dbu_price`| Contract price for automated DBUs                                                                               | number || yes     |
|`sql_compute_dbu_price`| Contract price for DBSQL DBUs                                                                                   | number || yes     |
|`jobs_light_dbu_price`| Contract price for interactive DBUs                                                                             | number || yes     |
|`max_days`| This is the max incremental days that will be loaded. Usually only relevant for historical loading and rebuilds | number || yes     |
|`excluded_scopes`| Scopes that should not be excluded from the pipelines                                                           | string || no      |
|`active`| Whether or not the workspace should be validated / deployed                                                     | bool   || yes     |
|`proxy_host`| Proxy url for the workspace                                                                                     | string || no      |
|`proxy_port`| Proxy port for the workspace                                           | string || no      |
|`proxy_user_name`| Proxy user name for the workspace                                                     | string || no      |
|`proxy_password_scope`| Scope which contains the proxy password key                                                     | string || no      |
|`proxy_password_key`| Key which contains proxy password                                                     | string || no      |
|`success_batch_size`|API Tunable - Indicates the size of the buffer on filling of which the result will be written to a temp location | string || no      |
|`error_batch_size`| API Tunable - Indicates the size of the error writer buffer containing API call errors                             | string || no      |
|`enable_unsafe_SSL`| API Tunable - Enables unsafe SSL                     | bool   || no      |
|`thread_pool_size`| API Tunable - Max number of API calls Overwatch is allowed to make in parallel                           | number || no      |
|`api_waiting_time`| API Tunable - Overwatch makes async api calls in parallel, api_waiting_time signifies the max wait time in case of no response received from the api call               | string || no      |
