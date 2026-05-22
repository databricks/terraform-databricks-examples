# examples/gcp-byovpc — Customer-managed VPC

Calls `modules/gcp/databricks-workspace` with `vpc_source = "create"`. Terraform
creates the spoke VPC + subnet + Cloud Router + NAT, then registers the network
with the Databricks account and provisions a workspace inside it.

## Prerequisites

- A GCP project with the Databricks platform onboarded
- A service account with workspace-creator role (see `examples/gcp-sa-provisioning`)
- Databricks account ID
- CIDR ranges for the spoke VPC and subnet that don't overlap with existing networks

## Apply

```bash
terraform init
terraform apply
```

## Migrating from the old example

This example previously called `modules/gcp-workspace-byovpc`. Several variable
names changed to match the new composer API:

| Old name | New name |
|----------|----------|
| `subnet_ip_cidr_range` | `subnet_cidr` |
| `pod_ip_cidr_range` | `pod_cidr` |
| `svc_ip_cidr_range` | `svc_cidr` |
| `subnet_name`, `router_name`, `nat_name` | (removed — composer derives from `prefix` + random suffix) |
| `delegate_from` | (removed — handled by `examples/gcp-sa-provisioning`) |
| _(new)_ | `spoke_vpc_cidr` (VPC primary CIDR, distinct from subnet CIDR) |

State from the old apply does **not** migrate cleanly to the new composer
because resource addresses differ. Re-apply on clean state.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 6.46.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_workspace"></a> [workspace](#module\_workspace) | ../../modules/gcp/databricks-workspace | n/a |

## Resources

| Name | Type |
|------|------|
| [google_client_config.current](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |
| [google_client_openid_userinfo.me](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_openid_userinfo) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_databricks_account_id"></a> [databricks\_account\_id](#input\_databricks\_account\_id) | Databricks Account ID | `string` | n/a | yes |
| <a name="input_databricks_google_service_account"></a> [databricks\_google\_service\_account](#input\_databricks\_google\_service\_account) | Service account email used for Databricks provider authentication | `string` | n/a | yes |
| <a name="input_google_project"></a> [google\_project](#input\_google\_project) | GCP project where the workspace VPC and resources will be created | `string` | n/a | yes |
| <a name="input_google_region"></a> [google\_region](#input\_google\_region) | GCP region for workspace deployment | `string` | n/a | yes |
| <a name="input_google_zone"></a> [google\_zone](#input\_google\_zone) | GCP zone (used by the google provider) | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix used to name generated resources | `string` | n/a | yes |
| <a name="input_spoke_vpc_cidr"></a> [spoke\_vpc\_cidr](#input\_spoke\_vpc\_cidr) | CIDR for the spoke VPC (e.g. 10.0.0.0/16) | `string` | n/a | yes |
| <a name="input_subnet_cidr"></a> [subnet\_cidr](#input\_subnet\_cidr) | CIDR for the GKE nodes subnet primary range (e.g. 10.0.0.0/22) | `string` | n/a | yes |
| <a name="input_workspace_name"></a> [workspace\_name](#input\_workspace\_name) | Workspace name | `string` | n/a | yes |
| <a name="input_pod_cidr"></a> [pod\_cidr](#input\_pod\_cidr) | Optional secondary range for GKE pods | `string` | `null` | no |
| <a name="input_svc_cidr"></a> [svc\_cidr](#input\_svc\_cidr) | Optional secondary range for GKE services | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_network_id"></a> [network\_id](#output\_network\_id) | databricks\_mws\_networks ID |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | ID of the spoke VPC created by the module |
| <a name="output_workspace_id"></a> [workspace\_id](#output\_workspace\_id) | Databricks workspace ID |
| <a name="output_workspace_url"></a> [workspace\_url](#output\_workspace\_url) | Databricks workspace URL |
<!-- END_TF_DOCS -->
