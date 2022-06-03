This module creates an Azure Databricks workspace with:
* Vnet Injection
* NPIP
* Azure Nat gateway. It can be replaced with a Load balancer or firewall.

Module creates:
* Resource group with random prefix
* Tags, including `Owner`, which is taken from `az account show --query user`
* VNet with public and private subnet
* Databricks workspace

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cidr | n/a | `any` | n/a | yes |
| no\_public\_ip | n/a | `bool` | `false` | no |
| private\_subnet\_endpoints | n/a | `list` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| arm\_client\_id | n/a |
| arm\_subscription\_id | n/a |
| arm\_tenant\_id | n/a |
| azure\_region | n/a |
| databricks\_azure\_workspace\_resource\_id | n/a |
| test\_resource\_group | n/a |
| workspace\_url | n/a |

