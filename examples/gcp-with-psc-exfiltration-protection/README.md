# examples/gcp-with-psc-exfiltration-protection — Workspace with PSC + private DNS + restricted egress

Calls `modules/gcp/databricks-workspace` with all PrivateLink and egress-control flags enabled:

- `vpc_source = "create"` — composer creates the spoke VPC + hub VPC + peering
- `private_link_frontend = true` — frontend PSC endpoint (workspace UI/API)
- `private_link_backend  = true` — backend (SCC) PSC endpoint (data plane)
- `private_access_only   = true` — `mws_private_access_settings.public_access_enabled = false`
- `restricted_egress     = true` — hub VPC + deny-egress firewall + private DNS zones

Optionally pairs with the `modules/gcp/unity-catalog` module to create a metastore, GCS bucket, storage credential, external location, and default catalog.

By default this example sets `serverless_egress_mode = "restricted"`, so serverless workloads are deny-by-default and must be explicitly allow-listed via `serverless_allowed_internet_destinations`/`serverless_allowed_storage_destinations` (matching the classic-compute egress posture set up by `restricted_egress`); set it to `"unmanaged"` to opt out. The example also exposes optional CMEK (`cmek_managed_services_key_id`, `cmek_storage_key_id`) and security-settings variables (Compliance Security Profile, Enhanced Security Monitoring, IP access lists) — all null/disabled unless set.

## Prerequisites

- Two (or three) GCP projects: workspace project, spoke VPC project, hub VPC project (can be the same)
- Service account with workspace-creator role (see `examples/gcp-sa-provisioning`)
- Databricks account ID
- CIDR ranges that don't overlap: `spoke_vpc_cidr`, `subnet_cidr` (subset of spoke), `hub_vpc_cidr`, `psc_subnet_cidr`

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

## Running this example

- Both the `databricks` (account-level) and `databricks` (workspace-level, used by `unity_catalog`/`security_settings`) provider configurations authenticate via Google Application Default Credentials — run `gcloud auth application-default login`, or use `google_service_account` impersonation. The module no longer creates or accepts a Databricks PAT.
- With `private_access_only = true` (the default here), the workspace has no public endpoint: the Unity Catalog and security-settings steps talk to the workspace over its URL, so the machine running `terraform apply` needs network reachability to the frontend PSC endpoint. Run it from a VM inside the hub/spoke network (or anything connected to it via VPN/peering) — not from an arbitrary laptop on the public internet.
- Serverless egress control (`serverless_egress_mode`) and CMEK (`cmek_managed_services_key_id`/`cmek_storage_key_id`) both require the workspace to be on the Enterprise tier.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | ~> 1.81 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 6.17 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_security_settings"></a> [security\_settings](#module\_security\_settings) | ../../modules/databricks/security-settings | n/a |
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
| <a name="input_cmek_managed_services_key_id"></a> [cmek\_managed\_services\_key\_id](#input\_cmek\_managed\_services\_key\_id) | Cloud KMS key resource ID for managed-services CMEK (control-plane data: notebooks, secrets, queries). Null disables. The principal running Terraform needs cloudkms.cryptoKeys.getIamPolicy and setIamPolicy on the key - Databricks sets the key's IAM policy at workspace creation. Enterprise tier; set at creation only. The key must exist before plan (a key created in the same configuration makes the count unknown and fails plan) | `string` | `null` | no |
| <a name="input_cmek_storage_key_id"></a> [cmek\_storage\_key\_id](#input\_cmek\_storage\_key\_id) | Cloud KMS key resource ID for workspace-storage CMEK (GCS buckets and GCE persistent disks). Null disables. Same permission and tier requirements as cmek\_managed\_services\_key\_id; set at creation only. The key must exist before plan (a key created in the same configuration makes the count unknown and fails plan) | `string` | `null` | no |
| <a name="input_compliance_standards"></a> [compliance\_standards](#input\_compliance\_standards) | Compliance standards for the CSP (e.g. ["HIPAA"]). Only meaningful when enable\_compliance\_security\_profile=true | `list(string)` | `[]` | no |
| <a name="input_enable_automatic_cluster_update"></a> [enable\_automatic\_cluster\_update](#input\_enable\_automatic\_cluster\_update) | Enable automatic cluster update for the workspace | `bool` | `false` | no |
| <a name="input_enable_compliance_security_profile"></a> [enable\_compliance\_security\_profile](#input\_enable\_compliance\_security\_profile) | Enable the Compliance Security Profile on the workspace. WARNING: irreversible - CSP cannot be disabled once enabled. Requires enable\_enhanced\_security\_monitoring=true | `bool` | `false` | no |
| <a name="input_enable_enhanced_security_monitoring"></a> [enable\_enhanced\_security\_monitoring](#input\_enable\_enhanced\_security\_monitoring) | Enable Enhanced Security Monitoring (hardened images, monitoring agents) | `bool` | `false` | no |
| <a name="input_hive_metastore_ip"></a> [hive\_metastore\_ip](#input\_hive\_metastore\_ip) | Regional legacy Hive metastore IP. When set, an egress allow rule (tcp/3306) is created under restricted egress; when null, no rule is created. Workspaces using Unity Catalog (the default) do not need this. Regional IPs: https://docs.databricks.com/gcp/en/resources/ip-domain-region | `string` | `null` | no |
| <a name="input_ip_access_lists"></a> [ip\_access\_lists](#input\_ip\_access\_lists) | Workspace IP access lists. list\_type is ALLOW or BLOCK. A non-empty list also flips the enableIpAccessLists workspace conf | <pre>list(object({<br/>    label        = string<br/>    list_type    = string<br/>    ip_addresses = list(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_serverless_allowed_internet_destinations"></a> [serverless\_allowed\_internet\_destinations](#input\_serverless\_allowed\_internet\_destinations) | FQDNs serverless workloads may reach (only with serverless\_egress\_mode=restricted) | `list(string)` | `[]` | no |
| <a name="input_serverless_allowed_storage_destinations"></a> [serverless\_allowed\_storage\_destinations](#input\_serverless\_allowed\_storage\_destinations) | GCS bucket names serverless workloads may reach (only with serverless\_egress\_mode=restricted) | `list(string)` | `[]` | no |
| <a name="input_serverless_egress_enforcement"></a> [serverless\_egress\_enforcement](#input\_serverless\_egress\_enforcement) | enforced or dry\_run (log-only evaluation) | `string` | `"enforced"` | no |
| <a name="input_serverless_egress_mode"></a> [serverless\_egress\_mode](#input\_serverless\_egress\_mode) | Serverless egress control mode (unmanaged, full, restricted). Default restricted: deny-by-default for serverless, matching this example's classic-compute posture. Requires Enterprise tier | `string` | `"restricted"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_hub_vpc_id"></a> [hub\_vpc\_id](#output\_hub\_vpc\_id) | ID of the hub VPC |
| <a name="output_network_id"></a> [network\_id](#output\_network\_id) | databricks\_mws\_networks ID |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | ID of the spoke VPC |
| <a name="output_workspace_id"></a> [workspace\_id](#output\_workspace\_id) | The Databricks workspace ID |
| <a name="output_workspace_url"></a> [workspace\_url](#output\_workspace\_url) | The workspace URL which is of the format '{workspaceId}.{random}.gcp.databricks.com' |
<!-- END_TF_DOCS -->
