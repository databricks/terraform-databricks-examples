# Provisioning AWS Databricks E2 with an AWS Firewall

This example is using the [aws-workspace-with-firewall](../../modules/aws-workspace-with-firewall) module.

This template provides an example of a simple deployment of AWS Databricks E2 workspace with an AWS Firewall.

## Overall Architecture

![alt text](https://raw.githubusercontent.com/databricks/terraform-databricks-examples/main/modules/aws-workspace-with-firewall/images/aws-workspace-with-firewall.png?raw=true)

## How to use

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

## Requirements

| Name                                                                         | Version  |
|------------------------------------------------------------------------------|----------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws)                      | ~> 5.0   |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | >=1.13.0 |

## Providers

| Name                                                       | Version |
|------------------------------------------------------------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | n/a     |

## Modules

| Name                                                                                                                  | Source                                                                                  | Version |
|-----------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------|---------|
| <a name="module_aws-workspace-with-firewall"></a> [aws-workspace-with-firewall](#module\_aws-workspace-with-firewall) | github.com/databricks/terraform-databricks-examples/modules/aws-workspace-with-firewall | n/a     |

## Resources

| Name                                                                                                          | Type     |
|---------------------------------------------------------------------------------------------------------------|----------|
| [random_string.naming](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name                                                                                                                                     | Description                                              | Type           | Default                                                                                      | Required |
|------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------|----------------|----------------------------------------------------------------------------------------------|:--------:|
| <a name="input_cidr_block"></a> [cidr\_block](#input\_cidr\_block)                                                                       | IP range for AWS VPC                                     | `string`       | `"10.4.0.0/16"`                                                                              |    no    |
| <a name="input_databricks_account_client_id"></a> [databricks\_account\_client\_id](#input\_databricks\_account\_client\_id)             | Application ID of account-level service principal        | `string`       | n/a                                                                                          |   yes    |
| <a name="input_databricks_account_client_secret"></a> [databricks\_account\_client\_secret](#input\_databricks\_account\_client\_secret) | Client secret of account-level service principal         | `string`       | n/a                                                                                          |   yes    |
| <a name="input_databricks_account_id"></a> [databricks\_account\_id](#input\_databricks\_account\_id)                                    | Databricks Account ID                                    | `string`       | n/a                                                                                          |   yes    |
| <a name="input_db_control_plane"></a> [db\_control\_plane](#input\_db\_control\_plane)                                                   | IP Range for AWS Databricks control plane                | `string`       | `"18.134.65.240/28"`                                                                         |    no    |
| <a name="input_db_rds"></a> [db\_rds](#input\_db\_rds)                                                                                   | Hostname of AWS RDS instance for built-in Hive Metastore | `string`       | `"mdio2468d9025m.c6fvhwk6cqca.eu-west-2.rds.amazonaws.com"`                                  |    no    |
| <a name="input_db_tunnel"></a> [db\_tunnel](#input\_db\_tunnel)                                                                          | Hostname of Databricks SCC Relay                         | `string`       | `"tunnel.eu-west-2.cloud.databricks.com"`                                                    |    no    |
| <a name="input_db_web_app"></a> [db\_web\_app](#input\_db\_web\_app)                                                                     | Hostname of Databricks web application                   | `string`       | `"london.cloud.databricks.com"`                                                              |    no    |
| <a name="input_prefix"></a> [prefix](#input\_prefix)                                                                                     | Prefix for use in the generated names                    | `string`       | `"demo"`                                                                                     |    no    |
| <a name="input_region"></a> [region](#input\_region)                                                                                     | AWS region to deploy to                                  | `string`       | `"eu-west-2"`                                                                                |    no    |
| <a name="input_tags"></a> [tags](#input\_tags)                                                                                           | Optional tags to add to created resources                | `map(string)`  | `{}`                                                                                         |    no    |
| <a name="input_whitelisted_urls"></a> [whitelisted\_urls](#input\_whitelisted\_urls)                                                     | List of the domains to allow traffic to                  | `list(string)` | <pre>[<br/>  ".pypi.org",<br/>  ".pythonhosted.org",<br/>  ".cran.r-project.org"<br/>]</pre> |    no    |

## Outputs

No outputs.