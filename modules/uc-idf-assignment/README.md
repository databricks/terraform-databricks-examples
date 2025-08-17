# Unity Catalog & Identity Federation assignment

This module contains Terraform code used to assign Unity Catalog and enable Identity Federation on a selected workspace.

## Module content

This module can be used to perform following tasks:

* Assign given Unity Catalog metastore to a specified workspace
* Assign groups & service principals to a specified workspace

## How to use

> **Note**  
> A deployment example using this module can be found in [examples/adb-lakehouse](../../examples/adb-lakehouse)

1. Reference this module using one of the different [module source types](https://developer.hashicorp.com/terraform/language/modules/sources)
2. Add a `variables.tf` with the same content in [variables.tf](variables.tf)
3. Add a `terraform.tfvars` file and provide values to each defined variable
4. Add a `output.tf` file.
5. (Optional) Configure your [remote backend](https://developer.hashicorp.com/terraform/language/settings/backends/azurerm)
6. Run `terraform init` to initialize terraform and get provider ready.
7. Run `terraform apply` to create the resources.


<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_databricks"></a> [databricks](#provider\_databricks) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [databricks_metastore_assignment.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/metastore_assignment) | resource |
| [databricks_mws_permission_assignment.groups-workspace-assignement](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_permission_assignment) | resource |
| [databricks_mws_permission_assignment.sp-workspace-assignement](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_permission_assignment) | resource |
| [databricks_group.account_groups](https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/group) | data source |
| [databricks_service_principal.sp](https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/service_principal) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_metastore_id"></a> [metastore\_id](#input\_metastore\_id) | The ID of Unity Catalog metastore | `string` | n/a | yes |
| <a name="input_workspace_id"></a> [workspace\_id](#input\_workspace\_id) | The ID of Databricks workspace | `string` | n/a | yes |
| <a name="input_account_groups"></a> [account\_groups](#input\_account\_groups) | List of databricks account groups we want to assign to the workspace | <pre>map(object({<br/>    group_name  = string<br/>    permissions = list(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_service_principals"></a> [service\_principals](#input\_service\_principals) | List of account-level service principals we want to assign to the workspace | <pre>map(object({<br/>    sp_id        = string<br/>    display_name = optional(string)<br/>    permissions  = list(string)<br/>  }))</pre> | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->