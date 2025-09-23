# Azure Databricks with Private Links (incl. web-auth PE) and Hub-Spoke Firewall structure (data exfiltration protection).

This example is using the [adb-with-private-links-exfiltration-protection](../../modules/adb-with-private-links-exfiltration-protection) module.

Include:
1. Hub-Spoke networking with egress firewall to control all outbound traffic, e.g. to pypi.org.
2. Private Link connection for backend traffic from data plane to control plane.
3. Private Link connection from user client to webapp service.
4. Private Link connection from data plane to dbfs storage.
5. Private Endpoint for web-auth traffic.

Overall Architecture:
![alt text](https://raw.githubusercontent.com/databricks/terraform-databricks-examples/main/modules/adb-with-private-links-exfiltration-protection/images/adb-private-links-general.png?raw=true)

With this deployment, traffic from user client to webapp (notebook UI), backend traffic from data plane to control plane will be through private endpoints. This terraform sample will create:
* Resource group with random prefix
* Tags, including `Owner`, which is taken from `az account show --query user`
* VNet with public and private subnet and subnet to host private endpoints
* Databricks workspace with private link to control plane, user to webapp and private link to dbfs


## How to use

1. Update `terraform.tfvars` file and provide values to each defined variable
2. (Optional) Configure your [remote backend](https://developer.hashicorp.com/terraform/language/settings/backends/azurerm)
3. Run `terraform init` to initialize terraform and get provider ready.
4. Run `terraform apply` to create the resources.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=4.0.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_adb_with_private_links_exfiltration_protection"></a> [adb\_with\_private\_links\_exfiltration\_protection](#module\_adb\_with\_private\_links\_exfiltration\_protection) | ../../modules/adb-with-private-links-exfiltration-protection | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_firewallfqdn"></a> [firewallfqdn](#input\_firewallfqdn) | Additional list of fully qualified domain names to add to firewall rules | `list(any)` | n/a | yes |
| <a name="input_metastoreip"></a> [metastoreip](#input\_metastoreip) | IP Address of built-in Hive Metastore in the target region | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Azure Subscription ID to deploy the workspace into | `string` | n/a | yes |
| <a name="input_create_resource_group"></a> [create\_resource\_group](#input\_create\_resource\_group) | Set to true to create a new Azure Resource Group. Set to false to use an existing Resource Group specified in existing\_resource\_group\_name | `bool` | `true` | no |
| <a name="input_dbfs_prefix"></a> [dbfs\_prefix](#input\_dbfs\_prefix) | Prefix for DBFS storage account name | `string` | `"dbfs"` | no |
| <a name="input_existing_resource_group_name"></a> [existing\_resource\_group\_name](#input\_existing\_resource\_group\_name) | Specify the name of an existing Resource Group only if you do not want Terraform to create a new one | `string` | `""` | no |
| <a name="input_hubcidr"></a> [hubcidr](#input\_hubcidr) | CIDR for Hub VNet | `string` | `"10.178.0.0/20"` | no |
| <a name="input_rglocation"></a> [rglocation](#input\_rglocation) | Location of resource group to create | `string` | `"southeastasia"` | no |
| <a name="input_spokecidr"></a> [spokecidr](#input\_spokecidr) | CIDR for Spoke VNet | `string` | `"10.179.0.0/20"` | no |
| <a name="input_workspace_prefix"></a> [workspace\_prefix](#input\_workspace\_prefix) | Prefix to use for Workspace name | `string` | `"adb"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_azure_resource_group_id"></a> [azure\_resource\_group\_id](#output\_azure\_resource\_group\_id) | ID of the created Azure resource group |
| <a name="output_resource_group"></a> [resource\_group](#output\_resource\_group) | ***Depricated***. Use azure\_resource\_group\_id instead |
| <a name="output_test_vm_public_ip"></a> [test\_vm\_public\_ip](#output\_test\_vm\_public\_ip) | Public IP of the Azure VM created for testing |
| <a name="output_workspace_azure_resource_id"></a> [workspace\_azure\_resource\_id](#output\_workspace\_azure\_resource\_id) | ***Depricated***. Use workspace\_id |
| <a name="output_workspace_id"></a> [workspace\_id](#output\_workspace\_id) | The Databricks workspace ID |
| <a name="output_workspace_url"></a> [workspace\_url](#output\_workspace\_url) | The Databricks workspace URL |
<!-- END_TF_DOCS -->