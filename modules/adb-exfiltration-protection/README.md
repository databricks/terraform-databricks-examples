# Provisioning Azure Databricks workspace with a Hub & Spoke firewall for data exfiltration protection

This module will create Azure Databricks workspace with a Hub & Spoke firewall for data exfiltration protection.

## Module content

This module can be used to deploy the following:

![alt text](https://raw.githubusercontent.com/databricks/terraform-databricks-examples/main/modules/adb-exfiltration-protection/images/adb-exfiltration-classic.png?raw=true)

* Resource group with random prefix
* Tags, including `Owner`, which is taken from `az account show --query user`
* Hub-Spoke topology, with hub firewall in hub vnet's subnet.
* Associated firewall rules, both FQDN and network rule using IP.


## How to use

> **Note**
> You can customize this module by adding, deleting or updating the Azure resources to adapt the module to your requirements.
> A deployment example using this module can be found in [examples/adb-exfiltration-protection](../../examples/adb-exfiltration-protection)

1. Reference this module using one of the different [module source types](https://developer.hashicorp.com/terraform/language/modules/sources)
2. Add a `variables.tf` with the same content in [variables.tf](variables.tf)
3. Add a `terraform.tfvars` file and provide values to each defined variable
4. Add a `output.tf` file.
5. (Optional) Configure your [remote backend](https://developer.hashicorp.com/terraform/language/settings/backends/azurerm)
6. Run `terraform init` to initialize terraform and get provider ready.
7. Run `terraform apply` to create the resources.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=4.0.0 |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | >=1.52.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=4.0.0 |
| <a name="provider_dns"></a> [dns](#provider\_dns) | n/a |
| <a name="provider_external"></a> [external](#provider\_external) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_databricks_workspace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/databricks_workspace) | resource |
| [azurerm_firewall.hubfw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall) | resource |
| [azurerm_firewall_application_rule_collection.adbfqdn](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall_application_rule_collection) | resource |
| [azurerm_firewall_network_rule_collection.adbfnetwork](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall_network_rule_collection) | resource |
| [azurerm_network_security_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_public_ip.fwpublicip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_route_table.adbroute](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_table) | resource |
| [azurerm_storage_account.allowedstorage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_account.deniedstorage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_subnet.hubfw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.private](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.public](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_network_security_group_association.private](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_subnet_network_security_group_association.public](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_subnet_route_table_association.privateudr](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_route_table_association) | resource |
| [azurerm_subnet_route_table_association.publicudr](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_route_table_association) | resource |
| [azurerm_virtual_network.hubvnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_virtual_network.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_virtual_network_peering.hubvnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |
| [azurerm_virtual_network_peering.spokevnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |
| [random_string.naming](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [dns_a_record_set.eventhubs](https://registry.terraform.io/providers/hashicorp/dns/latest/docs/data-sources/a_record_set) | data source |
| [dns_a_record_set.metastore](https://registry.terraform.io/providers/hashicorp/dns/latest/docs/data-sources/a_record_set) | data source |
| [dns_a_record_set.scc_relay](https://registry.terraform.io/providers/hashicorp/dns/latest/docs/data-sources/a_record_set) | data source |
| [external_external.me](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_resource_group"></a> [create\_resource\_group](#input\_create\_resource\_group) | Set to true to create a new Azure Resource Group. Set to false to use an existing Resource Group specified in existing\_resource\_group\_name | `bool` | n/a | yes |
| <a name="input_eventhubs"></a> [eventhubs](#input\_eventhubs) | List of FQDNs for Azure Databricks EventHubs traffic | `list(string)` | n/a | yes |
| <a name="input_existing_resource_group_name"></a> [existing\_resource\_group\_name](#input\_existing\_resource\_group\_name) | Specify the name of an existing Resource Group only if you do not want Terraform to create a new one | `string` | n/a | yes |
| <a name="input_firewallfqdn"></a> [firewallfqdn](#input\_firewallfqdn) | List of domains names to put into application rules for handling of HTTPS traffic (Databricks storage accounts, etc.) | `list(string)` | n/a | yes |
| <a name="input_metastore"></a> [metastore](#input\_metastore) | List of FQDNs for Azure Databricks Metastore databases | `list(string)` | n/a | yes |
| <a name="input_rglocation"></a> [rglocation](#input\_rglocation) | Location of resource group | `string` | n/a | yes |
| <a name="input_scc_relay"></a> [scc\_relay](#input\_scc\_relay) | List of FQDNs for Azure Databricks Secure Cluster Connectivity relay | `list(string)` | n/a | yes |
| <a name="input_webapp_ips"></a> [webapp\_ips](#input\_webapp\_ips) | List of IP ranges for Azure Databricks Webapp | `list(string)` | n/a | yes |
| <a name="input_bypass_scc_relay"></a> [bypass\_scc\_relay](#input\_bypass\_scc\_relay) | If we should bypass firewall for Secure Cluster Connectivity traffic or not | `bool` | `true` | no |
| <a name="input_dbfs_prefix"></a> [dbfs\_prefix](#input\_dbfs\_prefix) | Prefix for DBFS storage account name | `string` | `"dbfs"` | no |
| <a name="input_hubcidr"></a> [hubcidr](#input\_hubcidr) | IP range for creaiton of the Spoke VNet | `string` | `"10.178.0.0/20"` | no |
| <a name="input_private_subnet_endpoints"></a> [private\_subnet\_endpoints](#input\_private\_subnet\_endpoints) | n/a | `list` | `[]` | no |
| <a name="input_spokecidr"></a> [spokecidr](#input\_spokecidr) | IP range for creaiton of the Hub VNet | `string` | `"10.179.0.0/20"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to add to created resources | `map(string)` | `{}` | no |
| <a name="input_workspace_prefix"></a> [workspace\_prefix](#input\_workspace\_prefix) | Prefix for workspace name | `string` | `"adb"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arm_client_id"></a> [arm\_client\_id](#output\_arm\_client\_id) | **Deprecated** |
| <a name="output_arm_subscription_id"></a> [arm\_subscription\_id](#output\_arm\_subscription\_id) | **Deprecated** |
| <a name="output_arm_tenant_id"></a> [arm\_tenant\_id](#output\_arm\_tenant\_id) | **Deprecated** |
| <a name="output_azure_region"></a> [azure\_region](#output\_azure\_region) | **Deprecated** |
| <a name="output_azure_resource_group_id"></a> [azure\_resource\_group\_id](#output\_azure\_resource\_group\_id) | ID of the created Azure resource group |
| <a name="output_databricks_azure_workspace_resource_id"></a> [databricks\_azure\_workspace\_resource\_id](#output\_databricks\_azure\_workspace\_resource\_id) | **Deprecated** The ID of the Databricks Workspace in the Azure management plane |
| <a name="output_resource_group"></a> [resource\_group](#output\_resource\_group) | **Deprecated** |
| <a name="output_workspace_id"></a> [workspace\_id](#output\_workspace\_id) | The Databricks workspace ID |
| <a name="output_workspace_url"></a> [workspace\_url](#output\_workspace\_url) | The Databricks workspace URL |
<!-- END_TF_DOCS -->
