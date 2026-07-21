# AWS Databricks Workspace

This module creates a Databricks workspace on AWS (E2 platform) on top of networking and storage that you provide. It wires together the account-level building blocks required by a workspace:

* `databricks_mws_credentials` — registers the cross-account IAM role Databricks uses to manage resources in your AWS account.
* `databricks_mws_storage_configurations` — registers the root S3 bucket (DBFS root) for the workspace.
* `databricks_mws_networks` — registers your existing VPC, private subnets and security groups (customer-managed VPC).
* `databricks_mws_workspaces` — creates the workspace itself, combining the credentials, storage and network configuration.

Because it consumes an existing VPC, subnets, security groups, cross-account role and root bucket, this module is meant to be composed with a networking/IAM/storage layer (for example the [`aws-databricks-base-infra`](../aws-databricks-base-infra) module) rather than used on its own.

## How to use

1. Reference this module using one of the different [module source types](https://developer.hashicorp.com/terraform/language/modules/sources).
2. Provide values for the required variables (`region`, `vpc_id`, `security_group_ids`, `vpc_private_subnets`, `databricks_account_id`, `cross_account_role_arn`, `root_storage_bucket`).
3. Configure the `databricks` provider at account level with your account credentials.
4. Run `terraform init`.
5. Run `terraform apply`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | >=1.24.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_databricks"></a> [databricks](#provider\_databricks) | >=1.24.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [databricks_mws_credentials.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_credentials) | resource |
| [databricks_mws_networks.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_networks) | resource |
| [databricks_mws_storage_configurations.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_storage_configurations) | resource |
| [databricks_mws_workspaces.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_workspaces) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cross_account_role_arn"></a> [cross\_account\_role\_arn](#input\_cross\_account\_role\_arn) | (Required) AWS cross account role ARN that will be used for the Databricks workspace | `string` | n/a | yes |
| <a name="input_databricks_account_id"></a> [databricks\_account\_id](#input\_databricks\_account\_id) | (Required) Databricks Account ID | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | (Required) AWS region where the assets will be deployed | `string` | n/a | yes |
| <a name="input_root_storage_bucket"></a> [root\_storage\_bucket](#input\_root\_storage\_bucket) | (Required) AWS root storage bucket | `string` | n/a | yes |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | (Required) List of VPC network security group IDs | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | (Required) AWS VPC ID | `string` | n/a | yes |
| <a name="input_vpc_private_subnets"></a> [vpc\_private\_subnets](#input\_vpc\_private\_subnets) | (Required) AWS VPC Subnets where the Databricks workspace will be deployed | `list(string)` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | (Optional) Prefix for use in the generated names | `string` | `"demo"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Optional tags to add to created resources | `map(string)` | `{}` | no |
| <a name="input_workspace_name"></a> [workspace\_name](#input\_workspace\_name) | (Optional) Workspace Name for this module - if none are provided, the prefix will be used to name the workspace via coalesce() | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_databricks_host"></a> [databricks\_host](#output\_databricks\_host) | n/a |
| <a name="output_databricks_workspace_id"></a> [databricks\_workspace\_id](#output\_databricks\_workspace\_id) | n/a |
<!-- END_TF_DOCS -->
