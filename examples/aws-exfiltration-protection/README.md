# Provisioning AWS Databricks workspace with a Hub & Spoke firewall for data exfiltration protection

This example is using the [aws-exfiltration-protection](../../modules/aws-exfiltration-protection) module.

This template provides an example deployment of AWS Databricks E2 workspace with a Hub & Spoke firewall for data exfiltration protection. Details are described in [Data Exfiltration Protection With Databricks on AWS](https://www.databricks.com/blog/2021/02/02/data-exfiltration-protection-with-databricks-on-aws.html). 

## Overall Architecture

![alt text](https://raw.githubusercontent.com/databricks/terraform-databricks-examples/main/modules/aws-exfiltration-protection/images/aws-exfiltration-classic.png?raw=true)

## How to use

> **Note**  
> If you are using AWS Firewall to block most traffic but allow the URLs that Databricks needs to connect to, please update the configuration based on your region. You can get the configuration details for your region from [Firewall Appliance](https://docs.databricks.com/administration-guide/cloud-configurations/aws/customer-managed-vpc.html#firewall-appliance-infrastructure) document.
> 
> You can optionally enable Private Link in the variables. Enabling Private link on AWS requires Databricks "Enterprise" tier which is configured at the Databricks account level.


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
9. Run `terraform output -json` to print url (host) of the created Databricks workspace.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | 3.5.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws-exfiltration-protection"></a> [aws-exfiltration-protection](#module\_aws-exfiltration-protection) | github.com/databricks/terraform-databricks-examples/modules/aws-exfiltration-protection | n/a |

## Resources

| Name | Type |
|------|------|
| [random_string.naming](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_databricks_account_client_id"></a> [databricks\_account\_client\_id](#input\_databricks\_account\_client\_id) | Application ID of account-level service principal | `string` | n/a | yes |
| <a name="input_databricks_account_client_secret"></a> [databricks\_account\_client\_secret](#input\_databricks\_account\_client\_secret) | Client secret of account-level service principal | `string` | n/a | yes |
| <a name="input_databricks_account_id"></a> [databricks\_account\_id](#input\_databricks\_account\_id) | Databricks Account ID | `string` | n/a | yes |
| <a name="input_enable_private_link"></a> [enable\_private\_link](#input\_enable\_private\_link) | n/a | `bool` | `false` | no |
| <a name="input_hub_cidr_block"></a> [hub\_cidr\_block](#input\_hub\_cidr\_block) | IP range for hub AWS VPC | `string` | `"10.10.0.0/16"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix for use in the generated names | `string` | `"demo"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region to deploy to | `string` | `"eu-central-1"` | no |
| <a name="input_spoke_cidr_block"></a> [spoke\_cidr\_block](#input\_spoke\_cidr\_block) | IP range for spoke AWS VPC | `string` | `"10.173.0.0/16"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Optional tags to add to created resources | `map(string)` | `{}` | no |
| <a name="input_whitelisted_urls"></a> [whitelisted\_urls](#input\_whitelisted\_urls) | n/a | `list(string)` | <pre>[<br/>  ".pypi.org",<br/>  ".pythonhosted.org",<br/>  ".cran.r-project.org",<br/>  ".maven.org",<br/>  ".storage-download.googleapis.com",<br/>  ".spark-packages.org"<br/>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_databricks_host"></a> [databricks\_host](#output\_databricks\_host) | n/a |
<!-- END_TF_DOCS -->
