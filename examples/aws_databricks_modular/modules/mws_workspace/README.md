<!-- BEGIN_TF_DOCS -->
## Description

This module `mws_workspace` creates an E2 Databricks workspace into an existing customer managed VPC; the module contains 2 sub-modules: `mws_network` and `mws_storage`, which are 2 abstracted layers as pre-requisite for the E2 workspace creation.

## Providers

| Name                                                                   | Version |
| ---------------------------------------------------------------------- | ------- |
| <a name="provider_databricks"></a> [databricks](#provider\_databricks) | n/a     |

## Modules

| Name                                                                               | Source                | Version |
| ---------------------------------------------------------------------------------- | --------------------- | ------- |
| <a name="module_my_mws_network"></a> [my\_mws\_network](#module\_my\_mws\_network) | ./modules/mws_network | n/a     |
| <a name="module_my_root_bucket"></a> [my\_root\_bucket](#module\_my\_root\_bucket) | ./modules/mws_storage | n/a     |

## Resources

| Name                                                                                                                                 | Type     |
| ------------------------------------------------------------------------------------------------------------------------------------ | -------- |
| [databricks_mws_workspaces.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_workspaces) | resource |

## Inputs

| Name                                                                                                  | Description        | Type           | Default | Required |
| ----------------------------------------------------------------------------------------------------- | ------------------ | -------------- | ------- | :------: |
| <a name="input_credentials_id"></a> [credentials\_id](#input\_credentials\_id)                        | n/a                | `string`       | n/a     |   yes    |
| <a name="input_databricks_account_id"></a> [databricks\_account\_id](#input\_databricks\_account\_id) | n/a                | `string`       | n/a     |   yes    |
| <a name="input_existing_vpc_id"></a> [existing\_vpc\_id](#input\_existing\_vpc\_id)                   | for network config | `string`       | n/a     |   yes    |
| <a name="input_nat_gateways_id"></a> [nat\_gateways\_id](#input\_nat\_gateways\_id)                   | n/a                | `string`       | n/a     |   yes    |
| <a name="input_prefix"></a> [prefix](#input\_prefix)                                                  | n/a                | `string`       | n/a     |   yes    |
| <a name="input_private_subnet_pair"></a> [private\_subnet\_pair](#input\_private\_subnet\_pair)       | n/a                | `list(string)` | n/a     |   yes    |
| <a name="input_region"></a> [region](#input\_region)                                                  | n/a                | `string`       | n/a     |   yes    |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids)          | n/a                | `list(string)` | n/a     |   yes    |
| <a name="input_workspace_name"></a> [workspace\_name](#input\_workspace\_name)                        | n/a                | `string`       | n/a     |   yes    |

## Outputs

| Name                                                                          | Description |
| ----------------------------------------------------------------------------- | ----------- |
| <a name="output_workspace_url"></a> [workspace\_url](#output\_workspace\_url) | n/a         |
<!-- END_TF_DOCS -->