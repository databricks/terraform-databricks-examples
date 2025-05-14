# Provisioning Databricks on GCP workspace with a Hub & Spoke network architecture for data exfiltration protection

This example is using the [gcp-with-psc-exfiltration-protection](../../modules/gcp-with-psc-exfiltration-protection) module.

This template provides an example deployment of: Hub-Spoke networking with egress firewall to control all outbound traffic from Databricks subnets.

With this setup, you can setup firewall rules to block / allow egress traffic from your Databricks clusters. You can also use firewall to block all access to storage accounts, and use private endpoint connection to bypass this firewall, such that you allow access only to specific storage accounts.  


To find IP and FQDN for your deployment, go to: https://docs.gcp.databricks.com/en/resources/ip-domain-region.html

## Overall Architecture

![alt text](../../modules/gcp-with-psc-exfiltration-protection/images/architecture.png)

Resources to be created:
* Hub VPC and its subnet
* Spoke VPC and its subnets
* Peering between Hub and Spoke VPC
* Private Service Connect (PSC) endpoints
* DNS private and peering zones
* Firewall rules for Hub and Spoke VPCs
* Databricks workspace with private link to control plane, user to webapp and private link to DBFS




## How to use

1. Reference this module using one of the different [module source types](https://developer.hashicorp.com/terraform/language/modules/sources)
2. Add `terraform.tfvars` with the information about service principals to be provisioned at account level.

## How to fill in variable values

Variables have no default values in order to avoid misconfiguration

Most values are related to resources managed by Databricks. The required values can be found at: https://docs.gcp.databricks.com/en/resources/ip-domain-region.html

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name                                                                         | Version  |
|------------------------------------------------------------------------------|----------|
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | >=1.77.0 |
| <a name="requirement_google"></a> [google](#requirement\_google)             | 6.17.0   |

## Providers

No providers.

## Modules

| Name                                                                                                                                                        | Source                                             | Version |
|-------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------|---------|
| <a name="module_gcp_with_data_exfiltration_protection"></a> [gcp\_with\_data\_exfiltration\_protection](#module\_gcp\_with\_data\_exfiltration\_protection) | ../../modules/gcp-with-psc-exfiltration-protection | n/a     |

## Resources

No resources.

## Inputs

| Name                                                                                                             | Description                                             | Type          | Default | Required |
|------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------|---------------|---------|:--------:|
| <a name="input_databricks_account_id"></a> [databricks\_account\_id](#input\_databricks\_account\_id)            | Databricks Account ID                                   | `string`      | n/a     |   yes    |
| <a name="input_google_region"></a> [google\_region](#input\_google\_region)                                      | Google Cloud region where the resources will be created | `string`      | n/a     |   yes    |
| <a name="input_hive_metastore_ip"></a> [hive\_metastore\_ip](#input\_hive\_metastore\_ip)                        | Value of regional default Hive Metastore IP             | `string`      | n/a     |   yes    |
| <a name="input_hub_vpc_cidr"></a> [hub\_vpc\_cidr](#input\_hub\_vpc\_cidr)                                       | CIDR for Hub VPC                                        | `string`      | n/a     |   yes    |
| <a name="input_hub_vpc_google_project"></a> [hub\_vpc\_google\_project](#input\_hub\_vpc\_google\_project)       | Google Cloud project ID related to Hub VPC              | `string`      | n/a     |   yes    |
| <a name="input_is_spoke_vpc_shared"></a> [is\_spoke\_vpc\_shared](#input\_is\_spoke\_vpc\_shared)                | Whether the Spoke VPC is a Shared or a dedicated VPC    | `bool`        | n/a     |   yes    |
| <a name="input_prefix"></a> [prefix](#input\_prefix)                                                             | Prefix to use in generated resources name               | `string`      | n/a     |   yes    |
| <a name="input_psc_subnet_cidr"></a> [psc\_subnet\_cidr](#input\_psc\_subnet\_cidr)                              | CIDR for Spoke VPC                                      | `string`      | n/a     |   yes    |
| <a name="input_spoke_vpc_cidr"></a> [spoke\_vpc\_cidr](#input\_spoke\_vpc\_cidr)                                 | CIDR for Spoke VPC                                      | `string`      | n/a     |   yes    |
| <a name="input_spoke_vpc_google_project"></a> [spoke\_vpc\_google\_project](#input\_spoke\_vpc\_google\_project) | Google Cloud project ID related to Spoke VPC            | `string`      | n/a     |   yes    |
| <a name="input_tags"></a> [tags](#input\_tags)                                                                   | Map of tags to add to all resources                     | `map(string)` | `{}`    |    no    |
| <a name="input_workspace_google_project"></a> [workspace\_google\_project](#input\_workspace\_google\_project)   | Google Cloud project ID related to Databricks workspace | `string`      | n/a     |   yes    |

## Outputs

| Name                                                                          | Description                                                                          |
|-------------------------------------------------------------------------------|--------------------------------------------------------------------------------------|
| <a name="output_workspace_id"></a> [workspace\_id](#output\_workspace\_id)    | The Databricks workspace ID                                                          |
| <a name="output_workspace_url"></a> [workspace\_url](#output\_workspace\_url) | The workspace URL which is of the format '{workspaceId}.{random}.gcp.databricks.com' |
<!-- END_TF_DOCS -->