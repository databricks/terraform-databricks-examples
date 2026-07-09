# Provisioning a Google Service Account that can be used to deploy Databricks workspace on GCP
=========================

In this template, we show how to deploy a service account that can be used to deploy gcp workspaces.

In this template, we create a [Service Account](https://cloud.google.com/iam/docs/service-account-overview) with minimal permissions that allow to provision a workspacce with both managed and user-provisionned vpc.


## Requirements

- Your user that you use to delegate from needs a set of permissions detailed [here](https://docs.gcp.databricks.com/administration-guide/cloud-configurations/gcp/permissions.html#required-user-permissions-or-service-account-permissions-to-create-a-workspace)

- The built-in roles of Kubernetes Admin and Compute Storage Admin needs to be available

- you need to run `gcloud auth application-default login` and login with your google account

## Run as an SA 

You can do the same thing by provisioning a service account that will have the same permissions - and associate the key associated to it.


## Run the tempalte

- You need to fill in the variables.tf 
- run `terraform init`
- run `teraform apply`

## Usage

Run once per GCP project to provision the service account Databricks uses to deploy workspaces.

```hcl
module "service_account" {
  source = "github.com/databricks/terraform-databricks-examples//modules/gcp/service-account"

  google_project = "my-project"
  prefix         = "acme"
  delegate_from  = ["user:alice@example.com"]
}
```

The consumer must also configure `provider "google" {}` (project + region/zone) — this module does not carry its own provider configuration.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 7.39.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_project_iam_custom_role.workspace_creator](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_custom_role) | resource |
| [google_project_iam_member.workspace_creator](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_service_account.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_iam_policy.impersonatable](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_policy) | resource |
| [google_iam_policy.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/iam_policy) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_delegate_from"></a> [delegate\_from](#input\_delegate\_from) | Identities to allow to impersonate created service account (in form of user:user.name@example.com, group:deployers@example.com or serviceAccount:deployer@my-project.iam.gserviceaccount.com) | `list(string)` | n/a | yes |
| <a name="input_google_project"></a> [google\_project](#input\_google\_project) | Google project for VPC/workspace deployment | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix to use in generated service account name | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_service_account_email"></a> [service\_account\_email](#output\_service\_account\_email) | Add this email as a user in the Databricks account console |
<!-- END_TF_DOCS -->
