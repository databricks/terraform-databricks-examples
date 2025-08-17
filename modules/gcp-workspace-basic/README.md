gcp basic
=========================

In this template, we show how to deploy a workspace with managed vpc.


## Requirements

- You need to have run gcp-sa-provisionning and have a service account to fill in the variables.
- If you want to deploy to a new project, you will need to grant the custom role generated in that template to the service acount in the new project.
- The Service Account needs to be added as Databricks Admin in the account console

## Run as an SA 

You can do the same thing by provisionning a service account that will have the same permissions - and associate the key associated to it.


## Run the tempalte

- You need to fill in the variables.tf 
- run `terraform init`
- run `teraform apply`

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_databricks"></a> [databricks](#provider\_databricks) | n/a |
| <a name="provider_google"></a> [google](#provider\_google) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [databricks_mws_workspaces.databricks_workspace](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_workspaces) | resource |
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [google_client_config.current](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |
| [google_client_openid_userinfo.me](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_openid_userinfo) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_databricks_account_id"></a> [databricks\_account\_id](#input\_databricks\_account\_id) | Databricks Account ID | `string` | n/a | yes |
| <a name="input_delegate_from"></a> [delegate\_from](#input\_delegate\_from) | Identities to allow to impersonate created service account (in form of user:user.name@example.com, group:deployers@example.com or serviceAccount:sa1@project.iam.gserviceaccount.com) | `list(string)` | n/a | yes |
| <a name="input_google_project"></a> [google\_project](#input\_google\_project) | Google project for VCP/workspace deployment | `string` | n/a | yes |
| <a name="input_google_region"></a> [google\_region](#input\_google\_region) | Google region for VCP/workspace deployment | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix to use in generated VPC name | `string` | n/a | yes |
| <a name="input_workspace_name"></a> [workspace\_name](#input\_workspace\_name) | Name of the workspace to create | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_databricks_host"></a> [databricks\_host](#output\_databricks\_host) | n/a |
| <a name="output_databricks_token"></a> [databricks\_token](#output\_databricks\_token) | n/a |
<!-- END_TF_DOCS -->
