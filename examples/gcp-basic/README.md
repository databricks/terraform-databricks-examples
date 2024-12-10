# Provisioning Databricks workspace on GCP with managed VPC
=========================

In this template, we show how to deploy a workspace with managed VPC.


## Requirements

- You need to have run gcp-sa-provisionning and have a service account to fill in the variables.
- If you want to deploy to a new project, you will need to grant the custom role generated in that template to the service acount in the new project.
- The Service Account needs to be added as Databricks Admin in the account console

## Run as an SA 

You can do the same thing by provisionning a service account that will have the same permissions - and associate the key associated to it.


## Run the tempalte

- You need to fill in the `variables.tf`
- run `terraform init`
- run `teraform apply`


## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name                                                            | Source                                                                          | Version |
|-----------------------------------------------------------------|---------------------------------------------------------------------------------|---------|
| <a name="module_gcp-basic"></a> [gcp-basic](#module\_gcp-basic) | github.com/databricks/terraform-databricks-examples/modules/gcp-workspace-basic | n/a     |

## Resources

No resources.

## Inputs

| Name                                                                                                                                        | Description                                                                                                                                                                           | Type           | Default | Required |
|---------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------|---------|:--------:|
| <a name="input_databricks_account_id"></a> [databricks\_account\_id](#input\_databricks\_account\_id)                                       | Databricks Account ID                                                                                                                                                                 | `string`       | n/a     |   yes    |
| <a name="input_databricks_google_service_account"></a> [databricks\_google\_service\_account](#input\_databricks\_google\_service\_account) | Email of the service account used for deployment                                                                                                                                      | `string`       | n/a     |   yes    |
| <a name="input_delegate_from"></a> [delegate\_from](#input\_delegate\_from)                                                                 | Identities to allow to impersonate created service account (in form of user:user.name@example.com, group:deployers@example.com or serviceAccount:sa1@project.iam.gserviceaccount.com) | `list(string)` | n/a     |   yes    |
| <a name="input_google_project"></a> [google\_project](#input\_google\_project)                                                              | Google project for VCP/workspace deployment                                                                                                                                           | `string`       | n/a     |   yes    |
| <a name="input_google_region"></a> [google\_region](#input\_google\_region)                                                                 | Google region for VCP/workspace deployment                                                                                                                                            | `string`       | n/a     |   yes    |
| <a name="input_google_zone"></a> [google\_zone](#input\_google\_zone)                                                                       | Zone in GCP region                                                                                                                                                                    | `string`       | n/a     |   yes    |
| <a name="input_prefix"></a> [prefix](#input\_prefix)                                                                                        | Prefix to use in generated VPC name                                                                                                                                                   | `string`       | n/a     |   yes    |
| <a name="input_workspace_name"></a> [workspace\_name](#input\_workspace\_name)                                                              | Name of the workspace to create                                                                                                                                                       | `string`       | n/a     |   yes    |

## Outputs

| Name                                                                                   | Description |
|----------------------------------------------------------------------------------------|-------------|
| <a name="output_databricks_host"></a> [databricks\_host](#output\_databricks\_host)    | n/a         |
| <a name="output_databricks_token"></a> [databricks\_token](#output\_databricks\_token) | n/a         |