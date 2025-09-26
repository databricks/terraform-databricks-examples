# adb-overwatch-mws-config

This module deploys the required resources for a multi-workspace Overwatch deployment :
- Storage account and container to store Overwatch ETL output
- Role assignment of the SPN to the storage account created above
- Databricks secret scope backed with AKV to store the secrets needed on the main Overwatch workspace
- Databricks mount point to the container created above
- Databricks Overwatch [notebook runner](./notebooks/overwatch-runner.scala)
- Databricks job that will run Overwatch with the notebook above

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | n/a |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |
| <a name="provider_databricks"></a> [databricks](#provider\_databricks) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_role_assignment.data-contributor-role](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_storage_account.ow-sa](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_data_lake_gen2_filesystem.overwatch-db](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_data_lake_gen2_filesystem) | resource |
| [databricks_job.overwatch](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/job) | resource |
| [databricks_mount.overwatch_db](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mount) | resource |
| [databricks_notebook.overwatch_etl](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/notebook) | resource |
| [databricks_secret_scope.overwatch-akv](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/secret_scope) | resource |
| [azuread_service_principal.overwatch-spn](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/service_principal) | data source |
| [azurerm_databricks_workspace.overwatch-ws](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/databricks_workspace) | data source |
| [azurerm_key_vault.existing-kv](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) | data source |
| [azurerm_key_vault_secret.spn-key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) | data source |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_akv_name"></a> [akv\_name](#input\_akv\_name) | Azure Key-Vault name | `string` | n/a | yes |
| <a name="input_databricks_secret_scope_name"></a> [databricks\_secret\_scope\_name](#input\_databricks\_secret\_scope\_name) | Databricks secret scope name (backed by Azure Key-Vault) | `string` | n/a | yes |
| <a name="input_latest_dbr_lts"></a> [latest\_dbr\_lts](#input\_latest\_dbr\_lts) | Latest DBR LTS version | `string` | n/a | yes |
| <a name="input_overwatch_spn_app_id"></a> [overwatch\_spn\_app\_id](#input\_overwatch\_spn\_app\_id) | Azure SPN ID used to create the mount points | `string` | n/a | yes |
| <a name="input_overwatch_ws_name"></a> [overwatch\_ws\_name](#input\_overwatch\_ws\_name) | Overwatch workspace name | `string` | n/a | yes |
| <a name="input_ow_sa_name"></a> [ow\_sa\_name](#input\_ow\_sa\_name) | The name of the Overwatch ETL storage account | `string` | n/a | yes |
| <a name="input_random_string"></a> [random\_string](#input\_random\_string) | Random string used as a suffix for the resources names | `string` | n/a | yes |
| <a name="input_rg_name"></a> [rg\_name](#input\_rg\_name) | Resource group name | `string` | n/a | yes |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | Azure Tenant ID | `string` | n/a | yes |
| <a name="input_cron_job_schedule"></a> [cron\_job\_schedule](#input\_cron\_job\_schedule) | Cron expression to schedule the Overwatch Job | `string` | `"0 0 8 * * ?"` | no |
| <a name="input_cron_timezone_id"></a> [cron\_timezone\_id](#input\_cron\_timezone\_id) | Timezone for the cron schedule | `string` | `"Europe/Brussels"` | no |
| <a name="input_overwatch_job_notification_email"></a> [overwatch\_job\_notification\_email](#input\_overwatch\_job\_notification\_email) | Overwatch Job Notification Email | `string` | `"email@example.com"` | no |
| <a name="input_overwatch_version"></a> [overwatch\_version](#input\_overwatch\_version) | Overwatch library maven version | `string` | `"overwatch_2.12:0.7.1.0"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_databricks_mount_db_name"></a> [databricks\_mount\_db\_name](#output\_databricks\_mount\_db\_name) | Mount point name to the storage account where Overwatch will be writing the results |
| <a name="output_etl_storage_prefix"></a> [etl\_storage\_prefix](#output\_etl\_storage\_prefix) | Overwatch ETL storage prefix, which represents a mount point to the ETL storage account |
<!-- END_TF_DOCS -->