# Provisioning PrivateLink connections for Serverless compute on AWS Databricks

This example is using the [aws-serverless-privatelink-to-cloud-service](../../modules/aws-serverless-privatelink-to-cloud-service/) module.

This template provides an example deployment of AWS PrivateLink resources for Databricks Serverless compute to reach AWS native services (e.g. Lambda, Secrets Manager, Kinesis) securely and privately.

> **Note** 
> This architecture should not be used for S3. Databricks Serverless uses a Gateway type VPC Endpoint by default so S3 requests do not go over public Internet. If you would like to use PrivateLink for a dedicated connection, see [Configure private connectivity to AWS S3 storage buckets](https://docs.databricks.com/aws/en/security/network/serverless-network-security/pl-aws-resources) for a more direct and cost-effective method than this example.
> 
> Enabling Private link on AWS requires Databricks "Enterprise" tier which is configured at the Databricks account level.

## How to use

1. Reference this module using one of the different [module source types](https://developer.hashicorp.com/terraform/language/modules/sources)
2. Add a `variables.tf` with the same content in [variables.tf](variables.tf)
3. Add a `terraform.tfvars` file and provide values to each defined variable
4. Configure the following environment variables:
    * `TF_VAR_databricks_account_client_id`, set to the value of application ID of your Databricks account-level service principal with admin permission.
    * `TF_VAR_databricks_account_client_secret`, set to the value of the client secret for your Databricks account-level service principal.
    * `TF_VAR_databricks_account_id`, set to the value of the ID of your Databricks account. You can find this value in the corner of your Databricks account console.
5. (Optional) Configure your [remote backend](https://developer.hashicorp.com/terraform/language/settings/backends/s3)
6. Run `terraform init` to initialize terraform and get provider ready.
7. Run `terraform plan` to validate and preview the deployment.
8. Run `terraform apply` to create the resources.
9. Run `terraform output -json` to print outputs of the deployment.
10. Verify your connection from a Serverless notebook.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.10 |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | ~> 1.84 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_pl-secretsmanager"></a> [pl-secretsmanager](#module\_pl-secretsmanager) | ../../modules/aws-serverless-privatelink-to-cloud-service | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_databricks_account_client_id"></a> [databricks\_account\_client\_id](#input\_databricks\_account\_client\_id) | Application ID of account-level service principal | `string` | n/a | yes |
| <a name="input_databricks_account_client_secret"></a> [databricks\_account\_client\_secret](#input\_databricks\_account\_client\_secret) | Client secret of account-level service principal | `string` | n/a | yes |
| <a name="input_databricks_account_id"></a> [databricks\_account\_id](#input\_databricks\_account\_id) | Databricks Account ID | `string` | n/a | yes |
| <a name="input_network_connectivity_config_id"></a> [network\_connectivity\_config\_id](#input\_network\_connectivity\_config\_id) | The network connectivity config ID to use for the resources | `string` | n/a | yes |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | The private subnet IDs to use for the resources | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | n/a | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region to deploy to. | `string` | `"us-east-1"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Optional tags to add to created resources | `map(string)` | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->