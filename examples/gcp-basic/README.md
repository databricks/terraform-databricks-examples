# examples/gcp-basic — Databricks-managed VPC

Calls `modules/gcp/databricks-workspace` with `vpc_source = "databricks_managed"`.
The Databricks platform provisions the workspace VPC; you provide only the GCP
project, region, and prefix.

## Prerequisites

- A GCP project with the Databricks platform onboarded
- A service account with workspace-creator role (see `examples/gcp-sa-provisioning`)
- Databricks account ID

## Apply

```bash
terraform init
terraform apply
```

## Migrating from the old example

This example previously called `modules/gcp-workspace-basic`. State from the
old apply does **not** migrate cleanly to the new composer because the
`databricks_mws_workspaces` resource address differs. Re-apply on clean state.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | ~> 1.81 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 6.17 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_workspace"></a> [workspace](#module\_workspace) | ../../modules/gcp/databricks-workspace | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_databricks_account_id"></a> [databricks\_account\_id](#input\_databricks\_account\_id) | Databricks Account ID | `string` | n/a | yes |
| <a name="input_databricks_google_service_account"></a> [databricks\_google\_service\_account](#input\_databricks\_google\_service\_account) | Service account email used for Databricks provider authentication | `string` | n/a | yes |
| <a name="input_google_project"></a> [google\_project](#input\_google\_project) | GCP project where the workspace will be created | `string` | n/a | yes |
| <a name="input_google_region"></a> [google\_region](#input\_google\_region) | GCP region for workspace deployment | `string` | n/a | yes |
| <a name="input_google_zone"></a> [google\_zone](#input\_google\_zone) | GCP zone (used by the google provider) | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix used to name generated resources | `string` | n/a | yes |
| <a name="input_workspace_name"></a> [workspace\_name](#input\_workspace\_name) | Workspace name | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_workspace_id"></a> [workspace\_id](#output\_workspace\_id) | Databricks workspace ID |
| <a name="output_workspace_url"></a> [workspace\_url](#output\_workspace\_url) | Databricks workspace URL |
<!-- END_TF_DOCS -->
