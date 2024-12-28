# Provisioning Databricks on Azure with Private Link - Standard deployment

This module contains Terraform code used to deploy an Azure Databricks workspace with Azure Private Link.

> **Note**  
> An Azure VM is deployed using this module in order to test the connectivity to the Azure Databricks workspace. 

## Module content

This module can be used to deploy the following:

![Azure Databricks with Private Link - Standard](https://raw.githubusercontent.com/databricks/terraform-databricks-examples/main/modules/adb-with-private-link-standard/images/azure-private-link-standard.png?raw=true)

It covers a [standard deployment](https://learn.microsoft.com/en-us/azure/databricks/administration-guide/cloud-configurations/azure/private-link-standard) to configure Azure Databricks with Private Link:
* Two seperate VNets are used:
  * A transit VNet 
  * A customer Data Plane VNet
* A private endpoint is used for back-end connectivity and deployed in the customer Data Plane VNet.
* A private endpoint is used for front-end connectivity and deployed in the transit VNet.
* A private endpoint is used for web authentication and deployed in the transit VNet.
* A dedicated Databricks workspace, called Web Auth workspace, is used for web authentication traffic. This workspace is configured with the sub resource **browser_authentication** and deployed using subnets in the transit VNet.

## How to use

> **Note**  
> You can customize this module by adding, deleting or updating the Azure resources to adapt the module to your requirements.
> A deployment example using this module can be found in [examples/adb-with-private-link-standard](../../examples/adb-with-private-link-standard)

1. Reference this module using one of the different [module source types](https://developer.hashicorp.com/terraform/language/modules/sources)
2. Add a `variables.tf` with the same content in [variables.tf](variables.tf)
3. Add a `terraform.tfvars` file and provide values to each defined variable
4. Add a `output.tf` file.
5. (Optional) Configure your [remote backend](https://developer.hashicorp.com/terraform/language/settings/backends/azurerm)
6. Run `terraform init` to initialize terraform and get provider ready.
7. Run `terraform apply` to create the resources.

## Requirements

| Name                                                                | Version |
|---------------------------------------------------------------------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=4.0.0 |

## Providers

| Name                                                             | Version |
|------------------------------------------------------------------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm)    | >=4.0.0 |
| <a name="provider_external"></a> [external](#provider\_external) | n/a     |
| <a name="provider_http"></a> [http](#provider\_http)             | n/a     |
| <a name="provider_random"></a> [random](#provider\_random)       | n/a     |

## Modules

No modules.

## Resources

| Name                                                                                                                                                                                                | Type        |
|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| [azurerm_databricks_workspace.dp_workspace](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/databricks_workspace)                                                   | resource    |
| [azurerm_databricks_workspace.transit_workspace](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/databricks_workspace)                                              | resource    |
| [azurerm_network_interface.testvmnic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface)                                                            | resource    |
| [azurerm_network_interface_security_group_association.testvmnsgassoc](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) | resource    |
| [azurerm_network_security_group.dp_sg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group)                                                      | resource    |
| [azurerm_network_security_group.testvm-nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group)                                                 | resource    |
| [azurerm_network_security_group.transit_sg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group)                                                 | resource    |
| [azurerm_network_security_rule.dp_aad](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule)                                                       | resource    |
| [azurerm_network_security_rule.dp_azfrontdoor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule)                                               | resource    |
| [azurerm_network_security_rule.test0](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule)                                                        | resource    |
| [azurerm_network_security_rule.transit_aad](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule)                                                  | resource    |
| [azurerm_network_security_rule.transit_azfrontdoor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule)                                          | resource    |
| [azurerm_private_dns_zone.dns_auth_front](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone)                                                         | resource    |
| [azurerm_private_dns_zone.dnsdbfs_blob](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone)                                                           | resource    |
| [azurerm_private_dns_zone.dnsdbfs_dfs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone)                                                            | resource    |
| [azurerm_private_dns_zone.dnsdpcp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone)                                                                | resource    |
| [azurerm_private_dns_zone_virtual_network_link.dbfsdnszonevnetlink_blob](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link)     | resource    |
| [azurerm_private_dns_zone_virtual_network_link.dbfsdnszonevnetlink_dfs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link)      | resource    |
| [azurerm_private_dns_zone_virtual_network_link.dpcpdnszonevnetlink](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link)          | resource    |
| [azurerm_private_dns_zone_virtual_network_link.transitdnszonevnetlink](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link)       | resource    |
| [azurerm_private_endpoint.dp_dbfspe_blob](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint)                                                         | resource    |
| [azurerm_private_endpoint.dp_dbfspe_dfs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint)                                                          | resource    |
| [azurerm_private_endpoint.dp_dpcp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint)                                                                | resource    |
| [azurerm_private_endpoint.front_pe](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint)                                                               | resource    |
| [azurerm_private_endpoint.transit_auth](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint)                                                           | resource    |
| [azurerm_public_ip.testvmpublicip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip)                                                                       | resource    |
| [azurerm_resource_group.dp_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group)                                                                      | resource    |
| [azurerm_resource_group.transit_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group)                                                                 | resource    |
| [azurerm_subnet.dp_plsubnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet)                                                                                | resource    |
| [azurerm_subnet.dp_private](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet)                                                                                 | resource    |
| [azurerm_subnet.dp_public](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet)                                                                                  | resource    |
| [azurerm_subnet.testvmsubnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet)                                                                               | resource    |
| [azurerm_subnet.transit_plsubnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet)                                                                           | resource    |
| [azurerm_subnet.transit_private](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet)                                                                            | resource    |
| [azurerm_subnet.transit_public](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet)                                                                             | resource    |
| [azurerm_subnet_network_security_group_association.dp_private](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association)           | resource    |
| [azurerm_subnet_network_security_group_association.dp_public](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association)            | resource    |
| [azurerm_subnet_network_security_group_association.transit_private](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association)      | resource    |
| [azurerm_subnet_network_security_group_association.transit_public](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association)       | resource    |
| [azurerm_virtual_network.dp_vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network)                                                                  | resource    |
| [azurerm_virtual_network.transit_vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network)                                                             | resource    |
| [azurerm_windows_virtual_machine.testvm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine)                                                   | resource    |
| [random_string.naming](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string)                                                                                       | resource    |
| [random_string.password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string)                                                                                     | resource    |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config)                                                                   | data source |
| [external_external.me](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external)                                                                                | data source |
| [http_http.my_public_ip](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http)                                                                                      | data source |

## Inputs

| Name                                                                                                                                     | Description                                                                     | Type           | Default | Required |
|------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------|----------------|---------|:--------:|
| <a name="input_cidr_dp"></a> [cidr\_dp](#input\_cidr\_dp)                                                                                | (Required) The CIDR for the Azure Data Plane VNet                               | `string`       | n/a     |   yes    |
| <a name="input_cidr_transit"></a> [cidr\_transit](#input\_cidr\_transit)                                                                 | (Required) The CIDR for the Azure transit VNet                                  | `string`       | n/a     |   yes    |
| <a name="input_location"></a> [location](#input\_location)                                                                               | (Required) The location for the resources in this module                        | `string`       | n/a     |   yes    |
| <a name="input_private_subnet_endpoints"></a> [private\_subnet\_endpoints](#input\_private\_subnet\_endpoints)                           | The list of Service endpoints to associate with the private subnet.             | `list(string)` | `[]`    |    no    |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled)          | (Optional, default: false) If access from the public networks should be enabled | `bool`         | `false` |    no    |
| <a name="input_transit_private_subnet_endpoints"></a> [transit\_private\_subnet\_endpoints](#input\_transit\_private\_subnet\_endpoints) | The list of Service endpoints to associate with the private transit subnet.     | `list(string)` | `[]`    |    no    |

## Outputs

| Name                                                                                                                                                                      | Description                                                                                             |
|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------|
| <a name="output_dp_databricks_azure_workspace_resource_id"></a> [dp\_databricks\_azure\_workspace\_resource\_id](#output\_dp\_databricks\_azure\_workspace\_resource\_id) | **Depricated** The ID of the Databricks Workspace in the Azure management plane.                        |
| <a name="output_dp_workspace_url"></a> [dp\_workspace\_url](#output\_dp\_workspace\_url)                                                                                  | **Depricated** Renamed to `workspace_url` to align with naming used in other modules                    |
| <a name="output_my_ip_addr"></a> [my\_ip\_addr](#output\_my\_ip\_addr)                                                                                                    | n/a                                                                                                     |
| <a name="output_test_vm_password"></a> [test\_vm\_password](#output\_test\_vm\_password)                                                                                  | Password to access the Test VM, use `terraform output -json test_vm_password` to get the password value |
| <a name="output_test_vm_public_ip"></a> [test\_vm\_public\_ip](#output\_test\_vm\_public\_ip)                                                                             | Public IP of the created virtual machine                                                                |
| <a name="output_workspace_id"></a> [workspace\_id](#output\_workspace\_id)                                                                                                | The Databricks workspace ID                                                                             |
| <a name="output_workspace_url"></a> [workspace\_url](#output\_workspace\_url)                                                                                             | The workspace URL which is of the format 'adb-{workspaceId}.{random}.azuredatabricks.net'               |
