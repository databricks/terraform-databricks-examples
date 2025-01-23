# adb-overwatch-main-ws

This module either creates a new workspace, or uses an existing one to deploy **Overwatch** 

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name                                                                                                    | Version |
|---------------------------------------------------------------------------------------------------------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm)                                           | n/a     |
| <a name="provider_databricks.ow-main-ws"></a> [databricks.ow-main-ws](#provider\_databricks.ow-main-ws) | n/a     |

## Modules

No modules.

## Resources

| Name                                                                                                                                                    | Type        |
|---------------------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| [azurerm_databricks_workspace.adb-new-ws](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/databricks_workspace)         | resource    |
| [azurerm_databricks_workspace.adb-existing-ws](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/databricks_workspace) | data source |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group)                          | data source |
| [databricks_spark_version.latest_lts](https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/spark_version)             | data source |

## Inputs

| Name                                                                                      | Description                                                                                                                                                 | Type     | Default | Required |
|-------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|---------|:--------:|
| <a name="input_overwatch_ws_name"></a> [overwatch\_ws\_name](#input\_overwatch\_ws\_name) | The name of an existing workspace, or the name to use to create a new one for Overwatch                                                                     | `string` | n/a     |   yes    |
| <a name="input_rg_name"></a> [rg\_name](#input\_rg\_name)                                 | Resource group name                                                                                                                                         | `string` | n/a     |   yes    |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id)         | Azure subscription ID                                                                                                                                       | `string` | n/a     |   yes    |
| <a name="input_use_existing_ws"></a> [use\_existing\_ws](#input\_use\_existing\_ws)       | A boolean that determines to either use an existing Databricks workspace for Overwatch, when it is set to true, or create a new one when it is set to false | `bool`   | n/a     |   yes    |

## Outputs

| Name                                                                                               | Description                |
|----------------------------------------------------------------------------------------------------|----------------------------|
| <a name="output_adb_ow_main_ws_url"></a> [adb\_ow\_main\_ws\_url](#output\_adb\_ow\_main\_ws\_url) | Overwatch workspace url    |
| <a name="output_latest_lts"></a> [latest\_lts](#output\_latest\_lts)                               | The latest DBR LTS version |
<!-- END_TF_DOCS -->