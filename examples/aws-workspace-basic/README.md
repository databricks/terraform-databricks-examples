# Provisioning AWS Databricks E2

This example is using the [aws-workspace-basic](../../modules/aws-workspace-basic) module.

This template provides an example of a simple deployment of AWS Databricks E2 workspace.

## Overall Architecture

![alt text](https://raw.githubusercontent.com/databricks/terraform-databricks-examples/main/modules/aws-workspace-basic/images/aws-workspace-basic.png?raw=true)

## How to use

1. Reference this module using one of the different [module source types](https://developer.hashicorp.com/terraform/language/modules/sources)
2. Add a `variables.tf` with the same content in [variables.tf](variables.tf)
3. Add a `terraform.tfvars` file and provide values to each defined variable
4. Configure authentication to the Databricks Account (i.e., via Databricks CLI profiles or service principal).
5. Add a `output.tf` file.
6. (Optional) Configure your [remote backend](https://developer.hashicorp.com/terraform/language/settings/backends/s3)
7. Run `terraform init` to initialize terraform and get provider ready.
8. Run `terraform apply` to create the resources.

## Requirements

| Name                                                                         | Version  |
|------------------------------------------------------------------------------|----------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws)                      | ~> 5.0   |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | >=1.13.0 |

## Providers

No providers.

## Modules

| Name                                                                                          | Source                                                                          | Version |
|-----------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------|---------|
| <a name="module_aws-workspace-basic"></a> [aws-workspace-basic](#module\_aws-workspace-basic) | github.com/databricks/terraform-databricks-examples/modules/aws-workspace-basic | n/a     |

## Resources

No resources.

## Inputs

| Name                                                                                                  | Description                               | Type          | Default         | Required |
|-------------------------------------------------------------------------------------------------------|-------------------------------------------|---------------|-----------------|:--------:|
| <a name="input_cidr_block"></a> [cidr\_block](#input\_cidr\_block)                                    | IP range for AWS VPC                      | `string`      | `"10.4.0.0/16"` |    no    |
| <a name="input_databricks_account_id"></a> [databricks\_account\_id](#input\_databricks\_account\_id) | Databricks Account ID                     | `string`      | n/a             |   yes    |
| <a name="input_region"></a> [region](#input\_region)                                                  | AWS region to deploy to                   | `string`      | `"eu-west-1"`   |    no    |
| <a name="input_tags"></a> [tags](#input\_tags)                                                        | Optional tags to add to created resources | `map(string)` | `{}`            |    no    |
| <a name="input_prefix"></a> [prefix](#input\_prefix)                                                        | Optional prefix to add to resource names | `string` | `""`            |    no    |

## Outputs

No outputs.
