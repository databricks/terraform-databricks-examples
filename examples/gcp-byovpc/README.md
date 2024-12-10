# Provisioning Databricks workspace on GCP with a custom VPC
=========================

In this template, we show how to deploy a workspace with a custom vpc.


## Requirements

- You need to have run gcp-sa-provisionning and have a service account to fill in the variables.
- If you want to deploy to a new project, you will need to grant the custom role generated in that template to the service acount in the new project.
- The sizing of the custom vpc subnets needs to be appropriate for the usage of the workspace. [This documentation covers it](https://docs.gcp.databricks.com/administration-guide/cloud-configurations/gcp/network-sizing.html)

## Run as an SA 

You can do the same thing by provisionning a service account that will have the same permissions - and associate the key associated to it.


## Run the tempalte

- You need to fill in the variables.tf 
- run `terraform init`
- run `teraform apply`

## Requirements

No requirements.

## Providers

| Name                                                       | Version |
|------------------------------------------------------------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a     |

## Modules

| Name                                                               | Source                                                                           | Version |
|--------------------------------------------------------------------|----------------------------------------------------------------------------------|---------|
| <a name="module_gcp-byovpc"></a> [gcp-byovpc](#module\_gcp-byovpc) | github.com/databricks/terraform-databricks-examples/modules/gcp-workspace-byovpc | n/a     |

## Resources

| Name                                                                                                                                         | Type        |
|----------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| [google_client_config.current](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config)              | data source |
| [google_client_openid_userinfo.me](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_openid_userinfo) | data source |

## Inputs

| Name                                                                                                                                        | Description                                                                                                                                                                           | Type           | Default | Required |
|---------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------|---------|:--------:|
| <a name="input_databricks_account_id"></a> [databricks\_account\_id](#input\_databricks\_account\_id)                                       | Databricks Account ID                                                                                                                                                                 | `string`       | n/a     |   yes    |
| <a name="input_databricks_google_service_account"></a> [databricks\_google\_service\_account](#input\_databricks\_google\_service\_account) | Email of the service account used for deployment                                                                                                                                      | `string`       | n/a     |   yes    |
| <a name="input_delegate_from"></a> [delegate\_from](#input\_delegate\_from)                                                                 | Identities to allow to impersonate created service account (in form of user:user.name@example.com, group:deployers@example.com or serviceAccount:sa1@project.iam.gserviceaccount.com) | `list(string)` | n/a     |   yes    |
| <a name="input_google_project"></a> [google\_project](#input\_google\_project)                                                              | Google project for VCP/workspace deployment                                                                                                                                           | `string`       | n/a     |   yes    |
| <a name="input_google_region"></a> [google\_region](#input\_google\_region)                                                                 | Google region for VCP/workspace deployment                                                                                                                                            | `string`       | n/a     |   yes    |
| <a name="input_google_zone"></a> [google\_zone](#input\_google\_zone)                                                                       | Zone in GCP region                                                                                                                                                                    | `string`       | n/a     |   yes    |
| <a name="input_nat_name"></a> [nat\_name](#input\_nat\_name)                                                                                | Name of the NAT service in compute router                                                                                                                                             | `string`       | n/a     |   yes    |
| <a name="input_pod_ip_cidr_range"></a> [pod\_ip\_cidr\_range](#input\_pod\_ip\_cidr\_range)                                                 | IP Range for Pods subnet (secondary)                                                                                                                                                  | `string`       | n/a     |   yes    |
| <a name="input_prefix"></a> [prefix](#input\_prefix)                                                                                        | Prefix to use in generated VPC name                                                                                                                                                   | `string`       | n/a     |   yes    |
| <a name="input_router_name"></a> [router\_name](#input\_router\_name)                                                                       | Name of the compute router to create                                                                                                                                                  | `string`       | n/a     |   yes    |
| <a name="input_subnet_ip_cidr_range"></a> [subnet\_ip\_cidr\_range](#input\_subnet\_ip\_cidr\_range)                                        | IP Range for Nodes subnet (primary)                                                                                                                                                   | `string`       | n/a     |   yes    |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name)                                                                       | Name of the subnet to create                                                                                                                                                          | `string`       | n/a     |   yes    |
| <a name="input_svc_ip_cidr_range"></a> [svc\_ip\_cidr\_range](#input\_svc\_ip\_cidr\_range)                                                 | IP Range for Services subnet (secondary)                                                                                                                                              | `string`       | n/a     |   yes    |

## Outputs

| Name                                                                                   | Description |
|----------------------------------------------------------------------------------------|-------------|
| <a name="output_databricks_host"></a> [databricks\_host](#output\_databricks\_host)    | n/a         |
| <a name="output_databricks_token"></a> [databricks\_token](#output\_databricks\_token) | n/a         |