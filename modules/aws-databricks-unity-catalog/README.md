# Module aws-databricks-unity-catalog

## Description

This module creates a Databricks Unity Catalog Metastore and Storage Credential for said metastore. It automatically creates an IAM role suitable for Unity Catalog and attaches it to the newly created metastore.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=4.57.0 |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | >=1.24.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >=4.57.0 |
| <a name="provider_databricks"></a> [databricks](#provider\_databricks) | >=1.24.1 |
| <a name="provider_time"></a> [time](#provider\_time) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.sample_data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.unity_metastore](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.metastore_data_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_s3_bucket.metastore](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_public_access_block.metastore](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.root_storage_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.versioning_example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [databricks_default_namespace_setting.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/default_namespace_setting) | resource |
| [databricks_metastore.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/metastore) | resource |
| [databricks_metastore_assignment.default_metastore](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/metastore_assignment) | resource |
| [databricks_metastore_data_access.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/metastore_data_access) | resource |
| [time_sleep.wait_role_creation](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_iam_policy_document.passrole_for_uc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | (Required) AWS account ID where the cross-account role for Unity Catalog will be created | `string` | n/a | yes |
| <a name="input_databricks_account_id"></a> [databricks\_account\_id](#input\_databricks\_account\_id) | (Required) Databricks Account ID | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | (Required) Prefix to name the resources created by this module | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | (Required) AWS region where the assets will be deployed | `string` | n/a | yes |
| <a name="input_unity_metastore_owner"></a> [unity\_metastore\_owner](#input\_unity\_metastore\_owner) | (Required) Name of the principal that will be the owner of the Metastore | `string` | n/a | yes |
| <a name="input_databricks_workspace_ids"></a> [databricks\_workspace\_ids](#input\_databricks\_workspace\_ids) | List of Databricks workspace IDs to be enabled with Unity Catalog.<br/>  Enter with square brackets and double quotes<br/>  e.g. ["111111111", "222222222"] | `list(string)` | `[]` | no |
| <a name="input_metastore_name"></a> [metastore\_name](#input\_metastore\_name) | (Optional) Name of the metastore that will be created | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) List of tags to be propagated across all assets in this demo | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_metastore_id"></a> [metastore\_id](#output\_metastore\_id) | Unity Catalog Metastore ID |
<!-- END_TF_DOCS -->
