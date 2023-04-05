# Azure Databricks with Private Links (incl. web-auth PE) and Hub-Spoke Firewall structure (data exfiltration protection).

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

> **Note**  
> You can customize this module by adding, deleting or updating the Azure resources to adapt the module to your requirements.
> A deployment example using this module can be found in [examples/adb-with-private-links-exfiltration-protection](../../examples/adb-with-private-links-exfiltration-protection)

1. Reference this module using one of the different [module source types](https://developer.hashicorp.com/terraform/language/modules/sources)
2. Add a `variables.tf` with the same content in [variables.tf](variables.tf)
3. Add a `terraform.tfvars` file and provide values to each defined variable
4. Add a `output.tf` file.
5. (Optional) Configure your [remote backend](https://developer.hashicorp.com/terraform/language/settings/backends/azurerm)
6. Run `terraform init` to initialize terraform and get provider ready.
7. Run `terraform apply` to create the resources.
