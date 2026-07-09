# GCP Databricks Workspace Composer

This module creates a complete Databricks workspace on Google Cloud Platform with full networking, connectivity, and authentication management.

Not to be confused with the workspace submodule (../workspace), which this composer calls to register the workspace with the Databricks control plane.

## Usage

```hcl
module "workspace" {
  source = "github.com/databricks/terraform-databricks-examples//modules/gcp/databricks-workspace"

  prefix                = "acme"
  databricks_account_id = var.databricks_account_id
  google_project        = "my-workspace-project"
  google_region         = "us-central1"

  vpc_source = { spoke = "databricks_managed" }   # spoke: or "create" / "existing"
}
```

See `examples/gcp-basic`, `examples/gcp-byovpc`, `examples/gcp-existing-vpc`, and `examples/gcp-with-psc-exfiltration-protection` for the four supported scenarios.

## Components

- **network**: VPC creation or integration (databricks_managed, create, or existing)
- **private_connectivity**: Private Service Connect (PSC) with optional frontend/backend
- **workspace**: Databricks MWS resources and workspace
- **dns**: Private DNS zones for restricted egress scenarios

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | >= 1.81.1 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | 3.9.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_dns"></a> [dns](#module\_dns) | ../dns | n/a |
| <a name="module_network"></a> [network](#module\_network) | ../network | n/a |
| <a name="module_private_connectivity"></a> [private\_connectivity](#module\_private\_connectivity) | ../private-connectivity | n/a |
| <a name="module_workspace"></a> [workspace](#module\_workspace) | ../workspace | n/a |

## Resources

| Name | Type |
|------|------|
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [terraform_data.preconditions](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_databricks_account_id"></a> [databricks\_account\_id](#input\_databricks\_account\_id) | Databricks account ID (GUID) where this workspace will be registered | `string` | n/a | yes |
| <a name="input_google_project"></a> [google\_project](#input\_google\_project) | GCP project ID hosting the workspace data plane | `string` | n/a | yes |
| <a name="input_google_region"></a> [google\_region](#input\_google\_region) | GCP region where the workspace will be deployed. When any private\_link\_* flag or restricted\_egress is true, the region must be supported by Databricks PSC (see preconditions.tf) | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix used to name generated resources (e.g. "acme" produces "acme-spoke-vpc-<suffix>") | `string` | n/a | yes |
| <a name="input_cmek_managed_services_key_id"></a> [cmek\_managed\_services\_key\_id](#input\_cmek\_managed\_services\_key\_id) | Cloud KMS key resource ID for managed-services CMEK (control-plane data: notebooks, secrets, queries). Null disables. The principal running Terraform needs cloudkms.cryptoKeys.getIamPolicy and setIamPolicy on the key - Databricks sets the key's IAM policy at workspace creation. Enterprise tier; set at creation only. The key must exist before plan (a key created in the same configuration makes the count unknown and fails plan) | `string` | `null` | no |
| <a name="input_cmek_storage_key_id"></a> [cmek\_storage\_key\_id](#input\_cmek\_storage\_key\_id) | Cloud KMS key resource ID for workspace-storage CMEK (GCS buckets and GCE persistent disks). Null disables. Same permission and tier requirements as cmek\_managed\_services\_key\_id; set at creation only. The key must exist before plan (a key created in the same configuration makes the count unknown and fails plan) | `string` | `null` | no |
| <a name="input_enable_hub_spoke_peering"></a> [enable\_hub\_spoke\_peering](#input\_enable\_hub\_spoke\_peering) | Create the bidirectional VPC peering between hub and spoke. Disable when hub-spoke connectivity is provided by other means (e.g. Shared VPC or an existing transit). Cloud DNS peering zones do not depend on it. Only takes effect when the hub is enabled | `bool` | `true` | no |
| <a name="input_existing_hub_subnet_name"></a> [existing\_hub\_subnet\_name](#input\_existing\_hub\_subnet\_name) | Name of the pre-existing hub subnet (must be in google\_region). Required when vpc\_source.hub=existing | `string` | `null` | no |
| <a name="input_existing_hub_vpc_name"></a> [existing\_hub\_vpc\_name](#input\_existing\_hub\_vpc\_name) | Name of the pre-existing hub VPC. Required when vpc\_source.hub=existing | `string` | `null` | no |
| <a name="input_existing_subnet_name"></a> [existing\_subnet\_name](#input\_existing\_subnet\_name) | Name of the pre-existing subnet to use (must be in google\_region). Required when vpc\_source.spoke=existing | `string` | `null` | no |
| <a name="input_existing_vpc_name"></a> [existing\_vpc\_name](#input\_existing\_vpc\_name) | Name of the pre-existing VPC to use. Required when vpc\_source.spoke=existing | `string` | `null` | no |
| <a name="input_hive_metastore_ip"></a> [hive\_metastore\_ip](#input\_hive\_metastore\_ip) | Regional legacy Hive metastore IP. When set, an egress allow rule (tcp/3306) is created under restricted egress; when null, no rule is created. Workspaces using Unity Catalog (the default) do not need this. Regional IPs: https://docs.databricks.com/gcp/en/resources/ip-domain-region | `string` | `null` | no |
| <a name="input_hub_vpc_cidr"></a> [hub\_vpc\_cidr](#input\_hub\_vpc\_cidr) | CIDR of the hub subnet (e.g. 10.1.0.0/24). Required when restricted\_egress=true and vpc\_source.hub=create | `string` | `null` | no |
| <a name="input_hub_vpc_google_project"></a> [hub\_vpc\_google\_project](#input\_hub\_vpc\_google\_project) | GCP project hosting the hub VPC. Required when restricted\_egress=true | `string` | `null` | no |
| <a name="input_is_spoke_vpc_shared"></a> [is\_spoke\_vpc\_shared](#input\_is\_spoke\_vpc\_shared) | If true and the spoke VPC project differs from the workspace project, bind the spoke project as a Shared-VPC host and the workspace project as a service project. Works with or without restricted\_egress | `bool` | `false` | no |
| <a name="input_private_access_only"></a> [private\_access\_only](#input\_private\_access\_only) | Create databricks\_mws\_private\_access\_settings with public\_access\_enabled=false. Workspace becomes reachable only through PSC endpoints | `bool` | `false` | no |
| <a name="input_private_link_backend"></a> [private\_link\_backend](#input\_private\_link\_backend) | Create the backend (SCC, data plane) PSC endpoint and a backend databricks\_mws\_vpc\_endpoint. On GCP both flags must be enabled together (see preconditions.tf) | `bool` | `false` | no |
| <a name="input_private_link_frontend"></a> [private\_link\_frontend](#input\_private\_link\_frontend) | Create the frontend (workspace UI/API) PSC endpoint and a frontend databricks\_mws\_vpc\_endpoint. On GCP both flags must be enabled together (see preconditions.tf) | `bool` | `false` | no |
| <a name="input_psc_subnet_cidr"></a> [psc\_subnet\_cidr](#input\_psc\_subnet\_cidr) | CIDR of the dedicated PSC subnet in the spoke VPC (e.g. 10.0.255.0/28). Required when restricted\_egress=true or any private\_link\_* flag is true | `string` | `null` | no |
| <a name="input_restricted_egress"></a> [restricted\_egress](#input\_restricted\_egress) | Create hub VPC + bidirectional peering + deny-egress firewall + private DNS zones. Requires vpc\_source.spoke=create and at least one private\_link\_* flag | `bool` | `false` | no |
| <a name="input_serverless_allowed_internet_destinations"></a> [serverless\_allowed\_internet\_destinations](#input\_serverless\_allowed\_internet\_destinations) | FQDNs serverless workloads may reach when serverless\_egress\_mode=restricted (max 100) | `list(string)` | `[]` | no |
| <a name="input_serverless_allowed_storage_destinations"></a> [serverless\_allowed\_storage\_destinations](#input\_serverless\_allowed\_storage\_destinations) | GCS bucket names serverless workloads may reach when serverless\_egress\_mode=restricted (max 100); region is taken from google\_region | `list(string)` | `[]` | no |
| <a name="input_serverless_egress_enforcement"></a> [serverless\_egress\_enforcement](#input\_serverless\_egress\_enforcement) | enforced: violations are blocked; dry\_run: violations are only logged (use to evaluate a policy before enforcing) | `string` | `"enforced"` | no |
| <a name="input_serverless_egress_mode"></a> [serverless\_egress\_mode](#input\_serverless\_egress\_mode) | Serverless egress control. unmanaged: no network policy resources; full: policy with FULL\_ACCESS; restricted: deny-by-default policy allowing only the listed destinations. Requires the workspace to be on the Enterprise tier | `string` | `"unmanaged"` | no |
| <a name="input_spoke_vpc_cidr"></a> [spoke\_vpc\_cidr](#input\_spoke\_vpc\_cidr) | CIDR of the spoke VPC address space (e.g. 10.0.0.0/16). Required when vpc\_source.spoke=create; ignored otherwise | `string` | `null` | no |
| <a name="input_spoke_vpc_google_project"></a> [spoke\_vpc\_google\_project](#input\_spoke\_vpc\_google\_project) | GCP project hosting the spoke VPC. Defaults to google\_project when null | `string` | `null` | no |
| <a name="input_subnet_cidr"></a> [subnet\_cidr](#input\_subnet\_cidr) | CIDR of the spoke subnet primary range (e.g. 10.0.0.0/22). Required when vpc\_source.spoke=create | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags. Currently not propagated to child resources; reserved for future use | `map(string)` | `{}` | no |
| <a name="input_vpc_source"></a> [vpc\_source](#input\_vpc\_source) | Where the workspace networks come from. spoke: databricks\_managed (no networking module called), create (Terraform creates VPC + subnet + NAT), existing (data-source lookup of existing\_vpc\_name/existing\_subnet\_name). hub — only relevant when spoke is create or existing, and only consumed when restricted\_egress=true: create (hub VPC + subnet created; hub\_vpc\_cidr required; the default when unset) or existing (lookup of existing\_hub\_vpc\_name/existing\_hub\_subnet\_name) | <pre>object({<br/>    spoke = optional(string, "databricks_managed")<br/>    hub   = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_workspace_name"></a> [workspace\_name](#input\_workspace\_name) | Optional workspace name override. Defaults to "prefix-ws-suffix" when null | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backend_endpoint_id"></a> [backend\_endpoint\_id](#output\_backend\_endpoint\_id) | Backend (SCC) mws\_vpc\_endpoint ID (null when private\_link\_backend=false) |
| <a name="output_backend_psc_ip_spoke"></a> [backend\_psc\_ip\_spoke](#output\_backend\_psc\_ip\_spoke) | IP address of the spoke-side backend PSC endpoint (null when no PSC) |
| <a name="output_frontend_endpoint_id"></a> [frontend\_endpoint\_id](#output\_frontend\_endpoint\_id) | Frontend mws\_vpc\_endpoint ID (null when private\_link\_frontend=false) |
| <a name="output_frontend_psc_ip_hub"></a> [frontend\_psc\_ip\_hub](#output\_frontend\_psc\_ip\_hub) | IP address of the hub-side frontend PSC endpoint (null when restricted\_egress=false) |
| <a name="output_frontend_psc_ip_spoke"></a> [frontend\_psc\_ip\_spoke](#output\_frontend\_psc\_ip\_spoke) | IP address of the spoke-side frontend PSC endpoint (null when no PSC) |
| <a name="output_google_region"></a> [google\_region](#output\_google\_region) | Region the workspace was deployed to (echo of input; convenient for downstream modules) |
| <a name="output_hub_vpc_id"></a> [hub\_vpc\_id](#output\_hub\_vpc\_id) | Hub VPC ID (null when restricted\_egress=false) |
| <a name="output_hub_vpc_self_link"></a> [hub\_vpc\_self\_link](#output\_hub\_vpc\_self\_link) | Hub VPC self-link (null when restricted\_egress=false) |
| <a name="output_nat_id"></a> [nat\_id](#output\_nat\_id) | Cloud NAT ID (null when vpc\_source.spoke != create or when restricted\_egress=true) |
| <a name="output_network_id"></a> [network\_id](#output\_network\_id) | databricks\_mws\_networks ID (null when vpc\_source.spoke=databricks\_managed) |
| <a name="output_private_access_settings_id"></a> [private\_access\_settings\_id](#output\_private\_access\_settings\_id) | databricks\_mws\_private\_access\_settings ID (null when private\_access\_only=false) |
| <a name="output_serverless_network_policy_id"></a> [serverless\_network\_policy\_id](#output\_serverless\_network\_policy\_id) | Serverless egress network-policy ID bound to the workspace (null when serverless\_egress\_mode=unmanaged) |
| <a name="output_spoke_subnet_id"></a> [spoke\_subnet\_id](#output\_spoke\_subnet\_id) | Spoke subnet ID (null when vpc\_source.spoke=databricks\_managed) |
| <a name="output_spoke_subnet_self_link"></a> [spoke\_subnet\_self\_link](#output\_spoke\_subnet\_self\_link) | Spoke subnet self-link (null when vpc\_source.spoke=databricks\_managed) |
| <a name="output_spoke_vpc_id"></a> [spoke\_vpc\_id](#output\_spoke\_vpc\_id) | Spoke VPC ID (null when vpc\_source.spoke=databricks\_managed) |
| <a name="output_spoke_vpc_self_link"></a> [spoke\_vpc\_self\_link](#output\_spoke\_vpc\_self\_link) | Spoke VPC self-link (null when vpc\_source.spoke=databricks\_managed) |
| <a name="output_suffix"></a> [suffix](#output\_suffix) | Random suffix used in resource names (useful when wiring downstream modules) |
| <a name="output_transit_endpoint_id"></a> [transit\_endpoint\_id](#output\_transit\_endpoint\_id) | Hub-side mws\_vpc\_endpoint ID (null when no hub or no frontend PSC) |
| <a name="output_workspace_id"></a> [workspace\_id](#output\_workspace\_id) | Databricks workspace ID |
| <a name="output_workspace_url"></a> [workspace\_url](#output\_workspace\_url) | Databricks workspace URL (https://<id>.<random>.gcp.databricks.com) |
<!-- END_TF_DOCS -->