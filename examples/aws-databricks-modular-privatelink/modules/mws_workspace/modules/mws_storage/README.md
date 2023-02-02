## Module for AWS Databricks workspace storage configuration

<!-- BEGIN_TF_DOCS -->
## Description

Returns a root bucket for workspace to use as dbfs. This module `mws_storage` is an abstract layer that wraps and returns `databricks_mws_storage_configurations`, which is a pre-requisite resource for the E2 workspace creation.

## Providers

| Name                                                                   | Version |
| ---------------------------------------------------------------------- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws)                      | n/a     |
| <a name="provider_databricks"></a> [databricks](#provider\_databricks) | n/a     |

## Modules

No modules.

## Resources

| Name                                                                                                                                                               | Type        |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------- |
| [aws_s3_bucket.root_storage_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)                                         | resource    |
| [aws_s3_bucket_policy.root_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy)                            | resource    |
| [aws_s3_bucket_public_access_block.root_storage_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource    |
| [databricks_mws_storage_configurations.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_storage_configurations)       | resource    |
| [databricks_aws_bucket_policy.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/aws_bucket_policy)                      | data source |

## Inputs

| Name                                                                                                  | Description | Type     | Default | Required |
| ----------------------------------------------------------------------------------------------------- | ----------- | -------- | ------- | :------: |
| <a name="input_databricks_account_id"></a> [databricks\_account\_id](#input\_databricks\_account\_id) | n/a         | `string` | n/a     |   yes    |
| <a name="input_region"></a> [region](#input\_region)                                                  | n/a         | `string` | n/a     |   yes    |
| <a name="input_root_bucket_name"></a> [root\_bucket\_name](#input\_root\_bucket\_name)                | n/a         | `string` | n/a     |   yes    |

## Outputs

| Name                                                                                                             | Description |
| ---------------------------------------------------------------------------------------------------------------- | ----------- |
| <a name="output_storage_configuration_id"></a> [storage\_configuration\_id](#output\_storage\_configuration\_id) | n/a         |
<!-- END_TF_DOCS -->