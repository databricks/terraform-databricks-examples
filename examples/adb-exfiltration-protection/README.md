# Provisioning Azure Databricks workspace with a Hub & Spoke firewall for data exfiltration protection

This example is using the [adb-exfiltration-protection](../../modules/adb-exfiltration-protection) module.

This template provides an example deployment of: Hub-Spoke networking with egress firewall to control all outbound traffic from Databricks subnets. Details are described in: https://databricks.com/blog/2020/03/27/data-exfiltration-protection-with-azure-databricks.html

With this setup, you can setup firewall rules to block / allow egress traffic from your Databricks clusters. You can also use firewall to block all access to storage accounts, and use private endpoint connection to bypass this firewall, such that you allow access only to specific storage accounts.  


To find IP and FQDN for your deployment, go to: https://docs.microsoft.com/en-us/azure/databricks/administration-guide/cloud-configurations/azure/udr

## Overall Architecture

![alt text](https://raw.githubusercontent.com/databricks/terraform-databricks-examples/main/modules/adb-exfiltration-protection/images/adb-exfiltration-classic.png?raw=true)

Resources to be created:
* Resource group with random prefix
* Tags, including `Owner`, which is taken from `az account show --query user`
* Hub-Spoke topology, with hub firewall in hub vnet's subnet.
* Associated firewall rules, both FQDN and network rule using IP.


## How to use

1. Update `terraform.tfvars` file and provide values to each defined variable.
2. (Optional) Configure your [remote backend](https://developer.hashicorp.com/terraform/language/settings/backends/azurerm)
3. Run `terraform init` to initialize terraform and get provider ready.
4. Run `terraform apply` to create the resources.

## How to fill in variable values

Some variables have no default value and will require one, e.g. `subscription_id` 

Most of the values are to be found at: https://docs.microsoft.com/en-us/azure/databricks/administration-guide/cloud-configurations/azure/udr

In `variables.tfvars`, set these variables:

metastoreip      = "40.78.233.2" # find your metastore service ip

sccip            = "52.230.27.216" # use nslookup on the domain name to find the ip

webappip         = "52.187.145.107/32" # given at UDR page

firewallfqdn = ["dbartifactsprodseap.blob.core.windows.net","dbartifactsprodeap.blob.core.windows.net","dblogprodseasia.blob.core.windows.net","prod-southeastasia-observabilityeventhubs.servicebus.windows.net","cdnjs.com"] # find these for your region, follow Databricks blog tutorial.


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=4.0.0 |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | >=1.52.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_adb-exfiltration-protection"></a> [adb-exfiltration-protection](#module\_adb-exfiltration-protection) | ../../modules/adb-exfiltration-protection | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_eventhubs"></a> [eventhubs](#input\_eventhubs) | List of FQDNs for Azure Databricks EventHubs traffic | `list(string)` | n/a | yes |
| <a name="input_firewallfqdn"></a> [firewallfqdn](#input\_firewallfqdn) | List of domains names to put into application rules for handling of HTTPS traffic (Databricks storage accounts, etc.) | `list(any)` | n/a | yes |
| <a name="input_metastore"></a> [metastore](#input\_metastore) | List of FQDNs for Azure Databricks Metastore databases | `list(string)` | n/a | yes |
| <a name="input_rglocation"></a> [rglocation](#input\_rglocation) | Location of resource group | `string` | n/a | yes |
| <a name="input_scc_relay"></a> [scc\_relay](#input\_scc\_relay) | List of FQDNs for Azure Databricks Secure Cluster Connectivity relay | `list(string)` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Azure Subscription ID to deploy the workspace into | `string` | n/a | yes |
| <a name="input_webapp_ips"></a> [webapp\_ips](#input\_webapp\_ips) | List of IP ranges for Azure Databricks Webapp | `list(string)` | n/a | yes |
| <a name="input_create_resource_group"></a> [create\_resource\_group](#input\_create\_resource\_group) | Set to true to create a new Azure Resource Group. Set to false to use an existing Resource Group specified in existing\_resource\_group\_name | `bool` | `true` | no |
| <a name="input_dbfs_prefix"></a> [dbfs\_prefix](#input\_dbfs\_prefix) | Prefix for DBFS storage account name | `string` | `"dbfs"` | no |
| <a name="input_existing_resource_group_name"></a> [existing\_resource\_group\_name](#input\_existing\_resource\_group\_name) | Specify the name of an existing Resource Group only if you do not want Terraform to create a new one | `string` | `""` | no |
| <a name="input_hubcidr"></a> [hubcidr](#input\_hubcidr) | IP range for creaiton of the Spoke VNet | `string` | `"10.178.0.0/20"` | no |
| <a name="input_spokecidr"></a> [spokecidr](#input\_spokecidr) | IP range for creaiton of the Hub VNet | `string` | `"10.179.0.0/20"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to add to created resources | `map(string)` | `{}` | no |
| <a name="input_workspace_prefix"></a> [workspace\_prefix](#input\_workspace\_prefix) | Prefix for workspace name | `string` | `"adb"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_azure_resource_group_id"></a> [azure\_resource\_group\_id](#output\_azure\_resource\_group\_id) | ID of the created Azure resource group |
| <a name="output_workspace_id"></a> [workspace\_id](#output\_workspace\_id) | The Databricks workspace ID |
| <a name="output_workspace_url"></a> [workspace\_url](#output\_workspace\_url) | The Databricks workspace URL |
<!-- END_TF_DOCS -->
