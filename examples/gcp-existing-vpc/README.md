# examples/gcp-existing-vpc — Use a pre-existing VPC

Calls `modules/gcp/databricks-workspace` with `vpc_source = "existing"`. Instead
of creating a VPC, the composer looks up the named VPC + subnet via Terraform
data sources and registers them with the Databricks account.

This is the scenario for organizations that manage GCP networking out-of-band
(e.g. via a platform team) and just want Databricks to consume an existing
network.

## Prerequisites

- A GCP project with the Databricks platform onboarded
- A pre-existing VPC and subnet in that project. The subnet must be in `google_region`.
- A service account with workspace-creator role (see `examples/gcp-sa-provisioning`)
- Databricks account ID

## Apply

```bash
terraform init
terraform apply
```

## What the composer does NOT do in this mode

- Does not create the VPC, subnet, router, or NAT — those must already exist
- Does not enforce that the subnet has Private Google Access enabled — verify in the console
- Does not configure egress firewalls or PrivateLink (those require `vpc_source = "create"`)

To layer PrivateLink onto an existing network, the current composer requires
`vpc_source = "create"`. Future work may relax this.

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
| <a name="input_existing_subnet_name"></a> [existing\_subnet\_name](#input\_existing\_subnet\_name) | Name of the pre-existing subnet inside the VPC (must be in google\_region) | `string` | n/a | yes |
| <a name="input_existing_vpc_name"></a> [existing\_vpc\_name](#input\_existing\_vpc\_name) | Name of the pre-existing GCP VPC to deploy the workspace into | `string` | n/a | yes |
| <a name="input_google_project"></a> [google\_project](#input\_google\_project) | GCP project hosting the existing VPC and subnet (also the workspace project) | `string` | n/a | yes |
| <a name="input_google_region"></a> [google\_region](#input\_google\_region) | GCP region for workspace deployment (must match the existing subnet's region) | `string` | n/a | yes |
| <a name="input_google_zone"></a> [google\_zone](#input\_google\_zone) | GCP zone (used by the google provider) | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix used to name Databricks-side resources (mws\_networks, mws\_workspaces) | `string` | n/a | yes |
| <a name="input_workspace_name"></a> [workspace\_name](#input\_workspace\_name) | Workspace name | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_network_id"></a> [network\_id](#output\_network\_id) | databricks\_mws\_networks ID |
| <a name="output_workspace_id"></a> [workspace\_id](#output\_workspace\_id) | Databricks workspace ID |
| <a name="output_workspace_url"></a> [workspace\_url](#output\_workspace\_url) | Databricks workspace URL |
<!-- END_TF_DOCS -->
