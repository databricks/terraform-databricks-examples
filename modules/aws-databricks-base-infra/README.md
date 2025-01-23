# AWS Databricks Workspace 
This Terraform module creates the necessary AWS resources for setting up a Databricks workspace.

## Architecture Overview

Include:

1. An IAM cross-account role for Databricks to assume
2. An S3 bucket to serve as the root storage for Databricks
3. Necessary IAM policies and S3 bucket policies
4. VPC resources (implied by the outputs, but not directly created in the provided resource list)


## How to use

> **Note**  
> You can customize this module by adding, deleting or updating the AWS resources to adapt the module to your requirements.
> A deployment example using this module can be found in [examples/aws-workspace-basic](../../examples/aws-workspace-basic)


## How to use

1. Reference this module using one of the different [module source types](https://developer.hashicorp.com/terraform/language/modules/sources)
2. Add `terraform.tfvars` with the information about the required input variables.

## Requirements

| Name                                                                         | Version  |
|------------------------------------------------------------------------------|----------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws)                      | >=4.57.0 |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | >=1.24.1 |

## Providers

| Name                                                                               | Version  |
|------------------------------------------------------------------------------------|----------|
| <a name="provider_aws"></a> [aws](#provider\_aws)                                  | >=4.57.0 |
| <a name="provider_databricks"></a> [databricks](#provider\_databricks)             | >=1.24.1 |
| <a name="provider_databricks.mws"></a> [databricks.mws](#provider\_databricks.mws) | >=1.24.1 |

## Modules

| Name                                                                          | Source                                               | Version |
|-------------------------------------------------------------------------------|------------------------------------------------------|---------|
| <a name="module_vpc"></a> [vpc](#module\_vpc)                                 | terraform-aws-modules/vpc/aws                        | 5.7.0   |
| <a name="module_vpc_endpoints"></a> [vpc\_endpoints](#module\_vpc\_endpoints) | terraform-aws-modules/vpc/aws//modules/vpc-endpoints | 5.7.0   |

## Resources

| Name                                                                                                                                                                                                 | Type        |
|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| [aws_iam_role.cross_account_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                                                              | resource    |
| [aws_iam_role_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy)                                                                              | resource    |
| [aws_s3_bucket.root_storage_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)                                                                           | resource    |
| [aws_s3_bucket_policy.root_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy)                                                              | resource    |
| [aws_s3_bucket_public_access_block.root_storage_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block)                                   | resource    |
| [aws_s3_bucket_server_side_encryption_configuration.root_storage_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource    |
| [aws_s3_bucket_versioning.versioning_example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning)                                                      | resource    |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones)                                                                | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                                                                   | data source |
| [databricks_aws_assume_role_policy.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/aws_assume_role_policy)                                              | data source |
| [databricks_aws_bucket_policy.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/aws_bucket_policy)                                                        | data source |
| [databricks_aws_crossaccount_policy.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/aws_crossaccount_policy)                                            | data source |

## Inputs

| Name                                                                                                  | Description                                                                                                                   | Type           | Default | Required |
|-------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------|----------------|---------|:--------:|
| <a name="input_cidr_block"></a> [cidr\_block](#input\_cidr\_block)                                    | (Required) CIDR block for the VPC that will be used to create the Databricks workspace                                        | `string`       | n/a     |   yes    |
| <a name="input_databricks_account_id"></a> [databricks\_account\_id](#input\_databricks\_account\_id) | (Required) Databricks Account ID                                                                                              | `string`       | n/a     |   yes    |
| <a name="input_prefix"></a> [prefix](#input\_prefix)                                                  | (Required) Prefix for the resources deployed by this module                                                                   | `string`       | n/a     |   yes    |
| <a name="input_region"></a> [region](#input\_region)                                                  | (Required) AWS region where the resources will be deployed                                                                    | `string`       | n/a     |   yes    |
| <a name="input_roles_to_assume"></a> [roles\_to\_assume](#input\_roles\_to\_assume)                   | (Optional) List of AWS roles that the cross account role can pass to the clusters (important when creating instance profiles) | `list(string)` | n/a     |   yes    |
| <a name="input_tags"></a> [tags](#input\_tags)                                                        | (Required) Map of tags to be applied to the kinesis stream                                                                    | `map(string)`  | n/a     |   yes    |

## Outputs

| Name                                                                                                              | Description                                               |
|-------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------|
| <a name="output_cross_account_role_arn"></a> [cross\_account\_role\_arn](#output\_cross\_account\_role\_arn)      | AWS Cross account role arn                                |
| <a name="output_private_route_table_ids"></a> [private\_route\_table\_ids](#output\_private\_route\_table\_ids)   | IDs for the private route tables associated with this VPC |
| <a name="output_root_bucket"></a> [root\_bucket](#output\_root\_bucket)                                           | root bucket                                               |
| <a name="output_security_group_ids"></a> [security\_group\_ids](#output\_security\_group\_ids)                    | Security group ID for DB Compliant VPC                    |
| <a name="output_subnets"></a> [subnets](#output\_subnets)                                                         | private subnets for workspace creation                    |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id)                                                          | VPC ID                                                    |
| <a name="output_vpc_main_route_table_id"></a> [vpc\_main\_route\_table\_id](#output\_vpc\_main\_route\_table\_id) | ID for the main route table associated with this VPC      |
<!-- END_TF_DOCS -->