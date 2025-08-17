# Provisioning a Google Service Account that can be used to deploy Databricks workspace on GCP
=========================

In this template, we show how to deploy a service account that can be used to deploy Databricks workspace on GCP.

In this template, we create a [Service Account](https://cloud.google.com/iam/docs/service-account-overview) with minimal permissions that allow to provision a workspace with both managed and user-provisioned VPC.


## Requirements

- Your user that you use to delegate from needs a set of permissions detailed [here](https://docs.gcp.databricks.com/administration-guide/cloud-configurations/gcp/permissions.html#required-user-permissions-or-service-account-permissions-to-create-a-workspace)

- The built-in roles of Kubernetes Admin and Compute Storage Admin needs to be available

- you need to run `gcloud auth application-default login` and login with your google account

## Run as an SA 

You can do the same thing by provisioning a service account that will have the same permissions - and associate the key associated to it.


## Run the template

- You need to fill in the variables.tf 
- run `terraform init`
- run `teraform apply`

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_gcp-sa-provisioning"></a> [gcp-sa-provisioning](#module\_gcp-sa-provisioning) | github.com/databricks/terraform-databricks-examples/modules/gcp-sa-provisioning | n/a |

## Resources

| Name | Type |
|------|------|
| [google_client_openid_userinfo.me](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_openid_userinfo) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_delegate_from"></a> [delegate\_from](#input\_delegate\_from) | Identities to allow to impersonate created service account (in form of user:user.name@example.com, group:deployers@example.com or serviceAccount:sa1@project.iam.gserviceaccount.com) | `list(string)` | n/a | yes |
| <a name="input_google_project"></a> [google\_project](#input\_google\_project) | Google project for VCP/workspace deployment | `string` | n/a | yes |
| <a name="input_google_region"></a> [google\_region](#input\_google\_region) | GCP region for deployment | `string` | n/a | yes |
| <a name="input_google_zone"></a> [google\_zone](#input\_google\_zone) | Zone in GCP region | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix to use in generated service account name.  This should not contain underscores or dashes. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_service_account"></a> [service\_account](#output\_service\_account) | Add this email as a user in the Databricks account console |
<!-- END_TF_DOCS -->
