## This module uses an existing VPC, inject 2 subnets into the VPC.

<!-- BEGIN_TF_DOCS -->
## Description

This module `mws_network` is an abstract layer that wraps and returns `databricks_mws_networks`, which is a pre-requisite resource for the E2 workspace creation.

## Providers

| Name                                                                   | Version |
| ---------------------------------------------------------------------- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws)                      | n/a     |
| <a name="provider_databricks"></a> [databricks](#provider\_databricks) | n/a     |

## Modules

No modules.

## Resources

| Name                                                                                                                                                                | Type        |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_route_table.private_route_tables](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table)                                     | resource    |
| [aws_route_table_association.private_route_table_associations](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource    |
| [aws_subnet.private_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)                                                    | resource    |
| [databricks_mws_networks.mwsnetwork](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_networks)                              | resource    |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones)                               | data source |

## Inputs

| Name                                                                                                  | Description                                          | Type           | Default | Required |
| ----------------------------------------------------------------------------------------------------- | ---------------------------------------------------- | -------------- | ------- | :------: |
| <a name="input_aws_nat_gateway_id"></a> [aws\_nat\_gateway\_id](#input\_aws\_nat\_gateway\_id)        | n/a                                                  | `string`       | n/a     |   yes    |
| <a name="input_databricks_account_id"></a> [databricks\_account\_id](#input\_databricks\_account\_id) | n/a                                                  | `string`       | n/a     |   yes    |
| <a name="input_existing_vpc_id"></a> [existing\_vpc\_id](#input\_existing\_vpc\_id)                   | provide existing vpc id for resources to deploy into | `string`       | n/a     |   yes    |
| <a name="input_prefix"></a> [prefix](#input\_prefix)                                                  | n/a                                                  | `string`       | n/a     |   yes    |
| <a name="input_private_subnet_pair"></a> [private\_subnet\_pair](#input\_private\_subnet\_pair)       | contains only 2 subnets cidr blocks                  | `list(string)` | n/a     |   yes    |
| <a name="input_region"></a> [region](#input\_region)                                                  | n/a                                                  | `string`       | n/a     |   yes    |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids)          | n/a                                                  | `list(string)` | n/a     |   yes    |

## Outputs

| Name                                                                 | Description |
| -------------------------------------------------------------------- | ----------- |
| <a name="output_network_id"></a> [network\_id](#output\_network\_id) | n/a         |
<!-- END_TF_DOCS -->