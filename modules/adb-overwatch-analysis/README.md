# adb-overwatch-analysis

This module deploys the following Databricks [python notebooks](./notebooks) on an existing **Overwatch** workspace.
  ![Blank diagram](https://user-images.githubusercontent.com/103026825/233795155-566a9f1a-5ff2-4bfa-b940-4a4c5b898c6f.png)



<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |
| <a name="provider_databricks"></a> [databricks](#provider\_databricks) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [databricks_notebook.overwatch_analysis](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/notebook) | resource |
| [azurerm_databricks_workspace.adb-ws](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/databricks_workspace) | data source |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_overwatch_ws_name"></a> [overwatch\_ws\_name](#input\_overwatch\_ws\_name) | The name of the Overwatch workspace | `string` | n/a | yes |
| <a name="input_rg_name"></a> [rg\_name](#input\_rg\_name) | Resource group name | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
