# Deploying Overwatch on Azure Databricks

This example contains Terraform code used to deploy Overwatch using the following modules :
- [adb-overwatch-regional-config](../../modules/adb-overwatch-regional-config)
- [adb-overwatch-mws-config](../../modules/adb-overwatch-mws-config)
- [adb-overwatch-main-ws](../../modules/adb-overwatch-main-ws)
- [adb-overwatch-ws-to-monitor](../../modules/adb-overwatch-ws-to-monitor)
- [adb-overwatch-analysis](../../modules/adb-overwatch-analysis)


## Example content

This code uses the [multi-workspace deployment of Overwatch](https://databrickslabs.github.io/overwatch/deployoverwatch/cloudinfra/azure/#reference-architecturehttps://databrickslabs.github.io/overwatch/deployoverwatch/cloudinfra/azure/#reference-architecture). Overwatch runs in a dedicated, or existing, Azure Databricks workspace, and monitors the specified workspaces in the config file [overwatch_deployment_config.csv](./overwatch_deployment_config.csv). This configuration file is generated automatically by the module [adb-overwatch-ws-to-monitor](../../modules/adb-overwatch-ws-to-monitor).

  ![Overwatch_Arch_Azure](https://user-images.githubusercontent.com/103026825/230571464-5892c5c7-82c2-4808-9003-61b501b75f69.png?raw=true)

The deployment is structured as followed :
* Use an existing **Resource group**
* Deploy **Eventhubs** topic per workspace, that could be in the same **Eventhubs** namespace
* Deploy **Storage Accounts**, one for the cluster logs and one for Overwatch database output
* Deploy the dedicated **Azure Databricks** workspace, or use an existing one for Overwatch, with some Databricks quick-start notebooks to analyse the results
* Deploy **Azure Key Vault** to store the secrets
* Configure **Role Assignments** and **mounts** to attribute the necessary permissions
* Configure **Diagnostic Logs** on the Databricks workspaces to monitor

> **Note**  
> As Terraform requires providers and modules to be declared statically before deploying the resources, we are using in this example a [bash script](./dynamic_providers_modules_generation.sh)
> that generates the provider configurations for N workspaces along with the modules references.

## How to use

1. Configure the workspaces that will be observed by Overwatch in [workspaces_to_monitor.json](./workspaces_to_monitor.json)
2. Make the script [dynamic_providers_modules_generation.sh](./dynamic_providers_modules_generation.sh) executable : `chmod +x dynamic_providers_modules_generation.sh`
3. Update the `terraform.tfvars` file with your environment values 
4. Run the script [dynamic_providers_modules_generation.sh](./dynamic_providers_modules_generation.sh) : `./dynamic_providers_modules_generation.sh`. This will dynamically generate `providers_ws_to_monitor.tf` and `main_ws_to_monitor.tf` files with the right terraform setup for all the workspaces defined in [workspaces_to_monitor.json](./workspaces_to_monitor.json)
5. Run `terraform init` to initialize terraform and get provider ready
6. Run `terraform plan` to check the resources that are affected
7. Run `terraform apply` to create the resources

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_adb-overwatch-analysis"></a> [adb-overwatch-analysis](#module\_adb-overwatch-analysis) | ../../modules/adb-overwatch-analysis | n/a |
| <a name="module_adb-overwatch-main-ws"></a> [adb-overwatch-main-ws](#module\_adb-overwatch-main-ws) | ../../modules/adb-overwatch-main-ws | n/a |
| <a name="module_adb-overwatch-mws-config"></a> [adb-overwatch-mws-config](#module\_adb-overwatch-mws-config) | ../../modules/adb-overwatch-mws-config | n/a |
| <a name="module_adb-overwatch-regional-config"></a> [adb-overwatch-regional-config](#module\_adb-overwatch-regional-config) | ../../modules/adb-overwatch-regional-config | n/a |

## Resources

| Name | Type |
|------|------|
| [random_string.strapp](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ehn_name"></a> [ehn\_name](#input\_ehn\_name) | Eventhubs namespace name | `string` | n/a | yes |
| <a name="input_key_vault_prefix"></a> [key\_vault\_prefix](#input\_key\_vault\_prefix) | AKV prefix | `string` | n/a | yes |
| <a name="input_logs_sa_name"></a> [logs\_sa\_name](#input\_logs\_sa\_name) | Logs storage account name | `string` | n/a | yes |
| <a name="input_overwatch_spn_app_id"></a> [overwatch\_spn\_app\_id](#input\_overwatch\_spn\_app\_id) | Azure SPN application ID | `string` | n/a | yes |
| <a name="input_overwatch_spn_secret"></a> [overwatch\_spn\_secret](#input\_overwatch\_spn\_secret) | Azure SPN secret | `string` | n/a | yes |
| <a name="input_overwatch_ws_name"></a> [overwatch\_ws\_name](#input\_overwatch\_ws\_name) | Overwatch Databricks workspace name | `string` | n/a | yes |
| <a name="input_ow_sa_name"></a> [ow\_sa\_name](#input\_ow\_sa\_name) | Overwatch ETL storage account name | `string` | n/a | yes |
| <a name="input_rg_name"></a> [rg\_name](#input\_rg\_name) | Resource group name | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Azure subscription ID | `string` | n/a | yes |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | Azure tenant ID | `string` | n/a | yes |
| <a name="input_active"></a> [active](#input\_active) | Whether or not the workspace should be validated / deployed | `bool` | `true` | no |
| <a name="input_api_waiting_time"></a> [api\_waiting\_time](#input\_api\_waiting\_time) | API Tunable - Overwatch makes async api calls in parallel, api\_waiting\_time signifies the max wait time in case of no response received from the api call | `string` | `""` | no |
| <a name="input_auditlog_prefix_source_path"></a> [auditlog\_prefix\_source\_path](#input\_auditlog\_prefix\_source\_path) | Location of auditlog (AWS/GCP Only) | `string` | `""` | no |
| <a name="input_automated_dbu_price"></a> [automated\_dbu\_price](#input\_automated\_dbu\_price) | Contract price for automated DBUs | `number` | `0.3` | no |
| <a name="input_databricks_secret_scope_name"></a> [databricks\_secret\_scope\_name](#input\_databricks\_secret\_scope\_name) | Databricks secret scope name (backed by Azure Key-Vault) | `string` | `"overwatch-akv"` | no |
| <a name="input_enable_unsafe_SSL"></a> [enable\_unsafe\_SSL](#input\_enable\_unsafe\_SSL) | API Tunable - Enables unsafe SSL | `string` | `""` | no |
| <a name="input_error_batch_size"></a> [error\_batch\_size](#input\_error\_batch\_size) | API Tunable - Indicates the size of the error writer buffer containing API call errors | `string` | `""` | no |
| <a name="input_excluded_scopes"></a> [excluded\_scopes](#input\_excluded\_scopes) | Scopes that should not be excluded from the pipelines | `string` | `""` | no |
| <a name="input_interactive_dbu_price"></a> [interactive\_dbu\_price](#input\_interactive\_dbu\_price) | Contract price for interactive DBUs | `number` | `0.55` | no |
| <a name="input_jobs_light_dbu_price"></a> [jobs\_light\_dbu\_price](#input\_jobs\_light\_dbu\_price) | Contract price for interactive DBUs | `number` | `0.1` | no |
| <a name="input_max_days"></a> [max\_days](#input\_max\_days) | This is the max incremental days that will be loaded. Usually only relevant for historical loading and rebuilds | `number` | `30` | no |
| <a name="input_proxy_host"></a> [proxy\_host](#input\_proxy\_host) | Proxy url for the workspace | `string` | `""` | no |
| <a name="input_proxy_password_key"></a> [proxy\_password\_key](#input\_proxy\_password\_key) | Key which contains proxy password | `string` | `""` | no |
| <a name="input_proxy_password_scope"></a> [proxy\_password\_scope](#input\_proxy\_password\_scope) | Scope which contains the proxy password key | `string` | `""` | no |
| <a name="input_proxy_port"></a> [proxy\_port](#input\_proxy\_port) | Proxy port for the workspace | `string` | `""` | no |
| <a name="input_proxy_user_name"></a> [proxy\_user\_name](#input\_proxy\_user\_name) | Proxy user name for the workspace | `string` | `""` | no |
| <a name="input_sql_compute_dbu_price"></a> [sql\_compute\_dbu\_price](#input\_sql\_compute\_dbu\_price) | Contract price for DBSQL DBUs | `number` | `0.22` | no |
| <a name="input_success_batch_size"></a> [success\_batch\_size](#input\_success\_batch\_size) | API Tunable - Indicates the size of the buffer on filling of which the result will be written to a temp location. This is used to tune performance in certain circumstance | `string` | `""` | no |
| <a name="input_thread_pool_size"></a> [thread\_pool\_size](#input\_thread\_pool\_size) | API Tunable - Max number of API calls Overwatch is allowed to make in parallel | `string` | `""` | no |
| <a name="input_use_existing_overwatch_ws"></a> [use\_existing\_overwatch\_ws](#input\_use\_existing\_overwatch\_ws) | Overwatch ETL storage prefix, which represents a mount point to the ETL storage account | `string` | `false` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->