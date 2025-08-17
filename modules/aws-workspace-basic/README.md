# Provisioning AWS Databricks E2

This template provides an example of a simple deployment of AWS Databricks E2 workspace.

> **Note**  
> The following [Terraform guide](https://registry.terraform.io/providers/databricks/databricks/latest/docs/guides/aws-workspace) provides step-by-step instructions for this deployment. 

## Overall Architecture

![alt text](https://raw.githubusercontent.com/databricks/terraform-databricks-examples/main/modules/aws-workspace-basic/images/aws-workspace-basic.png?raw=true)

Resources to be created:
* VPC and VPC endpoints
* S3 Root bucket
* Cross-account IAM role
* Databricks E2 workspace


## How to use

> **Note**  
> You can customize this module by adding, deleting or updating the Azure resources to adapt the module to your requirements.
> A deployment example using this module can be found in [examples/aws-workspace-basic](../../examples/aws-workspace-basic)

1. Reference this module using one of the different [module source types](https://developer.hashicorp.com/terraform/language/modules/sources)
2. Add a `variables.tf` with the same content in [variables.tf](variables.tf)
3. Add a `terraform.tfvars` file and provide values to each defined variable
4. Configure the following environment variables:
    * TF_VAR_databricks_account_client_id, set to the value of application ID of your Databricks account-level service principal with admin permission.
    * TF_VAR_databricks_account_client_secret, set to the value of the client secret for your Databricks account-level service principal.
    * TF_VAR_databricks_account_id, set to the value of the ID of your Databricks account. You can find this value in the corner of your Databricks account console.
5. Add a `output.tf` file.
6. (Optional) Configure your [remote backend](https://developer.hashicorp.com/terraform/language/settings/backends/s3)
7. Run `terraform init` to initialize terraform and get provider ready.
8. Run `terraform apply` to create the resources.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | >=1.13.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_databricks"></a> [databricks](#provider\_databricks) | >=1.13.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |
| <a name="provider_time"></a> [time](#provider\_time) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 5.7.0 |
| <a name="module_vpc_endpoints"></a> [vpc\_endpoints](#module\_vpc\_endpoints) | terraform-aws-modules/vpc/aws//modules/vpc-endpoints | 5.7.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.cross_account_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_s3_bucket.root_storage_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.acl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_ownership_controls.state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.root_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.root_storage_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.root_storage_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [databricks_mws_credentials.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_credentials) | resource |
| [databricks_mws_networks.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_networks) | resource |
| [databricks_mws_storage_configurations.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_storage_configurations) | resource |
| [databricks_mws_workspaces.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_workspaces) | resource |
| [random_string.naming](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [time_sleep.wait](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [databricks_aws_assume_role_policy.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/aws_assume_role_policy) | data source |
| [databricks_aws_bucket_policy.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/aws_bucket_policy) | data source |
| [databricks_aws_crossaccount_policy.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/aws_crossaccount_policy) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_databricks_account_id"></a> [databricks\_account\_id](#input\_databricks\_account\_id) | Databricks Account ID | `string` | n/a | yes |
| <a name="input_cidr_block"></a> [cidr\_block](#input\_cidr\_block) | n/a | `string` | `"10.4.0.0/16"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix for use in the generated names | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region to deploy to | `string` | `"eu-west-2"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Optional tags to add to created resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_databricks_host"></a> [databricks\_host](#output\_databricks\_host) | n/a |
| <a name="output_databricks_token"></a> [databricks\_token](#output\_databricks\_token) | n/a |
| <a name="output_workspace_id"></a> [workspace\_id](#output\_workspace\_id) | n/a |
<!-- END_TF_DOCS -->