# Unity Catalog terraform blueprints

This module contains Terraform code used to provision a Databricks service principal on account-level.

## Module content

This module can be used to deploy the following:

* A Azure Databricks Service Principal

## How to use

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

| Name                                                                   | Version |
|------------------------------------------------------------------------|---------|
| <a name="provider_databricks"></a> [databricks](#provider\_databricks) | n/a     |

## Modules

No modules.

## Resources

| Name                                                                                                                                                               | Type     |
|--------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|
| [databricks_service_principal.databricks_service_principal](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/service_principal) | resource |

## Inputs

| Name                                                                                       | Description                                                        | Type                                                                                                                                        | Default | Required |
|--------------------------------------------------------------------------------------------|--------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------|---------|:--------:|
| <a name="input_service_principals"></a> [service\_principals](#input\_service\_principals) | list of service principals we want to create at Databricks account | <pre>map(object({<br/>    sp_id        = string<br/>    display_name = optional(string)<br/>    permissions  = list(string)<br/>  }))</pre> | `{}`    |    no    |

## Outputs

No outputs.

<!-- END_TF_DOCS -->