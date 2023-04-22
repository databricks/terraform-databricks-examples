# adb-overwatch-mws-config

This module deploys the required resources for a multi-workspace Overwatch deployment :
- Storage account and container to store Overwatch ETL output
- Role assignment of the SPN to the storage account created above
- Databricks secret scope backed with AKV to store the secrets needed on the main Overwatch workspace
- Databricks mount point to the container created above
- Databricks Overwatch [notebook runner](./notebooks/overwatch-runner.scala)
- Databricks job that will run Overwatch with the notebook above

## Inputs

| Name           | Description                                                                                                                                                    | Type   | Default               | Required |
|----------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------|--------|-----------------------|----------|
|`overwatch_ws_name`| Overwatch workspace name                                                                                                                                          | string || yes                   |
|`rg_name`| Resource group name                                                                                                                                            | string || yes                   |
|`overwatch_spn_app_id`| Azure SPN ID used to create the mount points                                                                        | string || yes                   |
|`tenant_id`| Azure Tenant ID | string || yes                   |
|`ow_sa_name`| The name of the Overwatch ETL storage account | string || yes                   |
|`akv_name`| Azure Key-Vault name | string || yes                   |
|`databricks_secret_scope_name`| Databricks secret scope name (backed by Azure Key-Vault) | string || yes                   |
|`overwatch_job_notification_email`| Overwatch Job Notification Email | string | email@example.com     | no       |
|`cron_job_schedule`| Cron expression to schedule the Overwatch Job | string | 0 0 8 * * ?           | no       |
|`cron_timezone_id`| Timezone for the cron schedule | string | Europe/Brussels       | no       |
|`overwatch_version`| Overwatch library maven version | string | overwatch_2.12:0.7.1.0 | yes      |
|`random_string`| Random string used as a suffix for the resources names | string || yes                   |
|`latest_dbr_lts`| Latest DBR LTS version | string | | yes      |

## Ouputs

| Name           | Description           |
|----------------|-----------------------|
|`etl_storage_prefix`| Overwatch ETL storage prefix, which represents a mount point to the ETL storage account |
|`databricks_mount_db_name`| Mount point name to the storage account where Overwatch will be writing the results |