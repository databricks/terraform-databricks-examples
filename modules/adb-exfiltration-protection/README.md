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