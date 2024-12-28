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

## Requirements

No requirements.

## Providers

| Name                                                                   | Version |
|------------------------------------------------------------------------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm)          | n/a     |
| <a name="provider_databricks"></a> [databricks](#provider\_databricks) | n/a     |
| <a name="provider_null"></a> [null](#provider\_null)                   | n/a     |
| <a name="provider_template"></a> [template](#provider\_template)       | n/a     |

## Modules

No modules.

## Resources

| Name                                                                                                                                                                             | Type        |
|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| [azurerm_eventhub.eh](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub)                                                                  | resource    |
| [azurerm_eventhub_authorization_rule.eh-ar](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_authorization_rule)                         | resource    |
| [azurerm_key_vault_secret.adb-pat](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret)                                             | resource    |
| [azurerm_key_vault_secret.eh-conn-string](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret)                                      | resource    |
| [azurerm_monitor_diagnostic_setting.dgs-ws](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting)                          | resource    |
| [azurerm_storage_data_lake_gen2_filesystem.cluster-logs-fs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_data_lake_gen2_filesystem)   | resource    |
| [databricks_mount.cluster-logs-mount-ws](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mount)                                              | resource    |
| [databricks_secret_scope.overwatch-akv](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/secret_scope)                                        | resource    |
| [databricks_token.pat-ws](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/token)                                                             | resource    |
| [null_resource.local](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource)                                                                     | resource    |
| [azurerm_databricks_workspace.adb-ws](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/databricks_workspace)                                   | data source |
| [azurerm_eventhub_namespace_authorization_rule.ehn-ar](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/eventhub_namespace_authorization_rule) | data source |
| [azurerm_key_vault.existing-kv](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault)                                                    | data source |
| [azurerm_key_vault_secret.spn-key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret)                                          | data source |
| [azurerm_monitor_diagnostic_categories.dgs-cat](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/monitor_diagnostic_categories)                | data source |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group)                                                   | data source |
| [azurerm_storage_account.logs-sa](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_account)                                            | data source |
| [template_cloudinit_config.local](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/cloudinit_config)                                          | data source |
| [template_file.ow-deployment-config](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file)                                                   | data source |

## Inputs

| Name                                                                                                                         | Description                                                                                                                                                                | Type     | Default | Required |
|------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|---------|:--------:|
| <a name="input_active"></a> [active](#input\_active)                                                                         | Whether or not the workspace should be validated / deployed                                                                                                                | `bool`   | n/a     |   yes    |
| <a name="input_adb_ws_name"></a> [adb\_ws\_name](#input\_adb\_ws\_name)                                                      | The name of an existing Databricks workspace that Overwatch will monitor                                                                                                   | `string` | n/a     |   yes    |
| <a name="input_akv_name"></a> [akv\_name](#input\_akv\_name)                                                                 | Azure Key-Vault name                                                                                                                                                       | `string` | n/a     |   yes    |
| <a name="input_api_waiting_time"></a> [api\_waiting\_time](#input\_api\_waiting\_time)                                       | API Tunable - Overwatch makes async api calls in parallel, api\_waiting\_time signifies the max wait time in case of no response received from the api call                | `string` | n/a     |   yes    |
| <a name="input_auditlog_prefix_source_path"></a> [auditlog\_prefix\_source\_path](#input\_auditlog\_prefix\_source\_path)    | Location of auditlog (AWS/GCP Only)                                                                                                                                        | `string` | n/a     |   yes    |
| <a name="input_automated_dbu_price"></a> [automated\_dbu\_price](#input\_automated\_dbu\_price)                              | Contract price for automated DBUs                                                                                                                                          | `number` | n/a     |   yes    |
| <a name="input_databricks_secret_scope_name"></a> [databricks\_secret\_scope\_name](#input\_databricks\_secret\_scope\_name) | Databricks secret scope name (backed by Azure Key-Vault)                                                                                                                   | `string` | n/a     |   yes    |
| <a name="input_ehn_auth_rule_name"></a> [ehn\_auth\_rule\_name](#input\_ehn\_auth\_rule\_name)                               | Eventhub namespace authorization rule name                                                                                                                                 | `string` | n/a     |   yes    |
| <a name="input_ehn_name"></a> [ehn\_name](#input\_ehn\_name)                                                                 | Eventhub namespace name                                                                                                                                                    | `string` | n/a     |   yes    |
| <a name="input_enable_unsafe_SSL"></a> [enable\_unsafe\_SSL](#input\_enable\_unsafe\_SSL)                                    | API Tunable - Enables unsafe SSL                                                                                                                                           | `string` | n/a     |   yes    |
| <a name="input_error_batch_size"></a> [error\_batch\_size](#input\_error\_batch\_size)                                       | API Tunable - Indicates the size of the error writer buffer containing API call errors                                                                                     | `string` | n/a     |   yes    |
| <a name="input_etl_storage_prefix"></a> [etl\_storage\_prefix](#input\_etl\_storage\_prefix)                                 | Overwatch ETL storage prefix, which represents a mount point to the ETL storage account                                                                                    | `string` | n/a     |   yes    |
| <a name="input_excluded_scopes"></a> [excluded\_scopes](#input\_excluded\_scopes)                                            | Scopes that should not be excluded from the pipelines                                                                                                                      | `string` | n/a     |   yes    |
| <a name="input_interactive_dbu_price"></a> [interactive\_dbu\_price](#input\_interactive\_dbu\_price)                        | Contract price for interactive DBUs                                                                                                                                        | `number` | n/a     |   yes    |
| <a name="input_jobs_light_dbu_price"></a> [jobs\_light\_dbu\_price](#input\_jobs\_light\_dbu\_price)                         | Contract price for interactive DBUs                                                                                                                                        | `number` | n/a     |   yes    |
| <a name="input_logs_sa_name"></a> [logs\_sa\_name](#input\_logs\_sa\_name)                                                   | Logs storage account name                                                                                                                                                  | `string` | n/a     |   yes    |
| <a name="input_max_days"></a> [max\_days](#input\_max\_days)                                                                 | This is the max incremental days that will be loaded. Usually only relevant for historical loading and rebuilds                                                            | `number` | n/a     |   yes    |
| <a name="input_overwatch_spn_app_id"></a> [overwatch\_spn\_app\_id](#input\_overwatch\_spn\_app\_id)                         | Azure SPN used to create Databricks mounts                                                                                                                                 | `string` | n/a     |   yes    |
| <a name="input_proxy_host"></a> [proxy\_host](#input\_proxy\_host)                                                           | Proxy url for the workspace                                                                                                                                                | `string` | n/a     |   yes    |
| <a name="input_proxy_password_key"></a> [proxy\_password\_key](#input\_proxy\_password\_key)                                 | Key which contains proxy password                                                                                                                                          | `string` | n/a     |   yes    |
| <a name="input_proxy_password_scope"></a> [proxy\_password\_scope](#input\_proxy\_password\_scope)                           | Scope which contains the proxy password key                                                                                                                                | `string` | n/a     |   yes    |
| <a name="input_proxy_port"></a> [proxy\_port](#input\_proxy\_port)                                                           | Proxy port for the workspace                                                                                                                                               | `string` | n/a     |   yes    |
| <a name="input_proxy_user_name"></a> [proxy\_user\_name](#input\_proxy\_user\_name)                                          | Proxy user name for the workspace                                                                                                                                          | `string` | n/a     |   yes    |
| <a name="input_random_string"></a> [random\_string](#input\_random\_string)                                                  | Random string used as a suffix for the resources names                                                                                                                     | `string` | n/a     |   yes    |
| <a name="input_rg_name"></a> [rg\_name](#input\_rg\_name)                                                                    | Resource group name                                                                                                                                                        | `string` | n/a     |   yes    |
| <a name="input_sql_compute_dbu_price"></a> [sql\_compute\_dbu\_price](#input\_sql\_compute\_dbu\_price)                      | Contract price for DBSQL DBUs                                                                                                                                              | `number` | n/a     |   yes    |
| <a name="input_success_batch_size"></a> [success\_batch\_size](#input\_success\_batch\_size)                                 | API Tunable - Indicates the size of the buffer on filling of which the result will be written to a temp location. This is used to tune performance in certain circumstance | `string` | n/a     |   yes    |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id)                                                              | Azure tenant ID                                                                                                                                                            | `string` | n/a     |   yes    |
| <a name="input_thread_pool_size"></a> [thread\_pool\_size](#input\_thread\_pool\_size)                                       | API Tunable - Max number of API calls Overwatch is allowed to make in parallel                                                                                             | `string` | n/a     |   yes    |

## Outputs

No outputs.