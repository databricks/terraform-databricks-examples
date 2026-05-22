# examples/gcp-with-psc-exfiltration-protection — Workspace with PSC + private DNS + restricted egress

Calls `modules/gcp/databricks-workspace` with all PrivateLink and egress-control flags enabled:

- `vpc_source = "create"` — composer creates the spoke VPC + hub VPC + peering
- `private_link_frontend = true` — frontend PSC endpoint (workspace UI/API)
- `private_link_backend  = true` — backend (SCC) PSC endpoint (data plane)
- `private_access_only   = true` — `mws_private_access_settings.public_access_enabled = false`
- `restricted_egress     = true` — hub VPC + deny-egress firewall + private DNS zones

Optionally pairs with the `modules/gcp/unity-catalog` module to create a metastore, GCS bucket, storage credential, external location, and default catalog.

## Prerequisites

- Two (or three) GCP projects: workspace project, spoke VPC project, hub VPC project (can be the same)
- Service account with workspace-creator role (see `examples/gcp-sa-provisioning`)
- Databricks account ID
- CIDR ranges that don't overlap: `spoke_vpc_cidr`, `subnet_cidr` (subset of spoke), `hub_vpc_cidr`, `psc_subnet_cidr`
- Regional default Hive Metastore IP from [Databricks docs](https://docs.gcp.databricks.com/en/resources/ip-domain-region.html#addresses-for-default-metastore)

## Apply

```bash
terraform init
terraform apply
```

## Migrating from the old example

This example previously called `modules/gcp-with-psc-exfiltration-protection` and `modules/gcp-unity-catalog`. Key changes:

| Old | New |
|-----|-----|
| `module.gcp_with_data_exfiltration_protection` | `module.workspace` |
| `modules/gcp-with-psc-exfiltration-protection` | `modules/gcp/databricks-workspace` with `vpc_source=create` + 4 PSC/egress flags |
| `modules/gcp-unity-catalog` | `modules/gcp/unity-catalog` (relocated, same interface) |
| `spoke_vpc_cidr` (legacy: was used as subnet CIDR AND firewall source ranges) | Split into `subnet_cidr` (subnet CIDR) and `spoke_vpc_cidr` (broader VPC CIDR for firewall source) |

State from the old apply does **not** migrate cleanly to the new composer because resource addresses differ. Re-apply on clean state.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | >=1.81.1 |
| <a name="requirement_google"></a> [google](#requirement\_google) | 6.17.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_unity_catalog"></a> [unity\_catalog](#module\_unity\_catalog) | ../../modules/gcp/unity-catalog | n/a |
| <a name="module_workspace"></a> [workspace](#module\_workspace) | ../../modules/gcp/databricks-workspace | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_catalog_name"></a> [catalog\_name](#input\_catalog\_name) | Name to assign to default Unity Catalog catalog | `string` | n/a | yes |
| <a name="input_databricks_account_id"></a> [databricks\_account\_id](#input\_databricks\_account\_id) | Databricks Account ID | `string` | n/a | yes |
| <a name="input_google_region"></a> [google\_region](#input\_google\_region) | Google Cloud region where the resources will be created | `string` | n/a | yes |
| <a name="input_hive_metastore_ip"></a> [hive\_metastore\_ip](#input\_hive\_metastore\_ip) | Regional default Hive Metastore IP (used by the spoke egress firewall to allow MySQL/3306) | `string` | n/a | yes |
| <a name="input_hub_vpc_cidr"></a> [hub\_vpc\_cidr](#input\_hub\_vpc\_cidr) | CIDR for the hub subnet | `string` | n/a | yes |
| <a name="input_hub_vpc_google_project"></a> [hub\_vpc\_google\_project](#input\_hub\_vpc\_google\_project) | Google Cloud project ID hosting the hub VPC | `string` | n/a | yes |
| <a name="input_is_spoke_vpc_shared"></a> [is\_spoke\_vpc\_shared](#input\_is\_spoke\_vpc\_shared) | Whether the spoke VPC project hosts a Shared VPC and the workspace project is bound as a service project | `bool` | n/a | yes |
| <a name="input_metastore_name"></a> [metastore\_name](#input\_metastore\_name) | Name to assign to regional Unity Catalog metastore | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix used to name generated resources | `string` | n/a | yes |
| <a name="input_psc_subnet_cidr"></a> [psc\_subnet\_cidr](#input\_psc\_subnet\_cidr) | CIDR for the dedicated PSC subnet in the spoke VPC | `string` | n/a | yes |
| <a name="input_spoke_vpc_cidr"></a> [spoke\_vpc\_cidr](#input\_spoke\_vpc\_cidr) | CIDR of the spoke VPC address space (used as source\_ranges for the hub ingress firewall) | `string` | n/a | yes |
| <a name="input_spoke_vpc_google_project"></a> [spoke\_vpc\_google\_project](#input\_spoke\_vpc\_google\_project) | Google Cloud project ID hosting the spoke VPC (often the same as workspace project) | `string` | n/a | yes |
| <a name="input_subnet_cidr"></a> [subnet\_cidr](#input\_subnet\_cidr) | CIDR for the spoke subnet (must be within spoke\_vpc\_cidr) | `string` | n/a | yes |
| <a name="input_workspace_google_project"></a> [workspace\_google\_project](#input\_workspace\_google\_project) | Google Cloud project ID where the Databricks workspace lives | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags applied to the composer (the composer accepts this but does not currently propagate to all submodules) | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_hub_vpc_id"></a> [hub\_vpc\_id](#output\_hub\_vpc\_id) | ID of the hub VPC |
| <a name="output_network_id"></a> [network\_id](#output\_network\_id) | databricks\_mws\_networks ID |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | ID of the spoke VPC |
| <a name="output_workspace_id"></a> [workspace\_id](#output\_workspace\_id) | The Databricks workspace ID |
| <a name="output_workspace_url"></a> [workspace\_url](#output\_workspace\_url) | The workspace URL which is of the format '{workspaceId}.{random}.gcp.databricks.com' |
<!-- END_TF_DOCS -->
