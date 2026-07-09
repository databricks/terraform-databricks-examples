# modules/gcp/workspace

Owns workspace registration with the Databricks control plane: `databricks_mws_*` resources for the GCP composer, including `mws_networks`, `mws_workspaces`, `mws_vpc_endpoint`, `mws_private_access_settings`.

## Usage

Typically called by `modules/gcp/databricks-workspace` (the composer). Direct consumption is supported but unusual.

```hcl
module "workspace" {
  source = "github.com/databricks/terraform-databricks-examples//modules/gcp/workspace"

  prefix                = "acme"
  suffix                = "abc123"
  databricks_account_id = var.databricks_account_id
  google_project        = "my-workspace-project"
  google_region         = "us-central1"
  vpc_source            = "databricks_managed"
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | >= 1.81.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_databricks"></a> [databricks](#provider\_databricks) | 1.120.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [databricks_account_network_policy.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/account_network_policy) | resource |
| [databricks_mws_customer_managed_keys.managed_services](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_customer_managed_keys) | resource |
| [databricks_mws_customer_managed_keys.storage](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_customer_managed_keys) | resource |
| [databricks_mws_networks.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_networks) | resource |
| [databricks_mws_private_access_settings.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_private_access_settings) | resource |
| [databricks_mws_vpc_endpoint.backend](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_vpc_endpoint) | resource |
| [databricks_mws_vpc_endpoint.frontend](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_vpc_endpoint) | resource |
| [databricks_mws_vpc_endpoint.transit](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_vpc_endpoint) | resource |
| [databricks_mws_workspaces.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_workspaces) | resource |
| [databricks_workspace_network_option.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/workspace_network_option) | resource |
| [terraform_data.nat_gate](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_databricks_account_id"></a> [databricks\_account\_id](#input\_databricks\_account\_id) | Databricks account ID (GUID) where this workspace will be registered | `string` | n/a | yes |
| <a name="input_google_project"></a> [google\_project](#input\_google\_project) | GCP project ID hosting the workspace data plane | `string` | n/a | yes |
| <a name="input_google_region"></a> [google\_region](#input\_google\_region) | GCP region where the workspace will be deployed | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix used to name generated resources | `string` | n/a | yes |
| <a name="input_suffix"></a> [suffix](#input\_suffix) | Random suffix appended to resource names for uniqueness (passed by the composer) | `string` | n/a | yes |
| <a name="input_vpc_source"></a> [vpc\_source](#input\_vpc\_source) | One of: databricks\_managed (no mws\_networks), create (we built the VPC), existing (data-source lookup) | `string` | n/a | yes |
| <a name="input_backend_forwarding_rule_name"></a> [backend\_forwarding\_rule\_name](#input\_backend\_forwarding\_rule\_name) | Name of the backend (SCC) PSC forwarding rule from private-connectivity; used as gcp\_vpc\_endpoint\_info.psc\_endpoint\_name | `string` | `null` | no |
| <a name="input_cmek_managed_services_key_id"></a> [cmek\_managed\_services\_key\_id](#input\_cmek\_managed\_services\_key\_id) | Cloud KMS key resource ID for managed-services CMEK (control-plane data: notebooks, secrets, queries). Null disables. The principal running Terraform needs cloudkms.cryptoKeys.getIamPolicy and setIamPolicy on the key - Databricks sets the key's IAM policy at workspace creation. Enterprise tier; set at creation only. The key must exist before plan (a key created in the same configuration makes the count unknown and fails plan) | `string` | `null` | no |
| <a name="input_cmek_storage_key_id"></a> [cmek\_storage\_key\_id](#input\_cmek\_storage\_key\_id) | Cloud KMS key resource ID for workspace-storage CMEK (GCS buckets and GCE persistent disks). Null disables. Same permission and tier requirements as cmek\_managed\_services\_key\_id; set at creation only. The key must exist before plan (a key created in the same configuration makes the count unknown and fails plan) | `string` | `null` | no |
| <a name="input_enable_backend"></a> [enable\_backend](#input\_enable\_backend) | Create the backend (SCC) mws\_vpc\_endpoint | `bool` | `false` | no |
| <a name="input_enable_frontend"></a> [enable\_frontend](#input\_enable\_frontend) | Create the frontend mws\_vpc\_endpoint (and, if hub\_frontend\_forwarding\_rule\_name is set, the transit endpoint) | `bool` | `false` | no |
| <a name="input_enable_hub"></a> [enable\_hub](#input\_enable\_hub) | Whether the hub exists (composer passes restricted\_egress). Gates the transit mws\_vpc\_endpoint; must be plan-time static | `bool` | `false` | no |
| <a name="input_frontend_forwarding_rule_name"></a> [frontend\_forwarding\_rule\_name](#input\_frontend\_forwarding\_rule\_name) | Name of the frontend PSC forwarding rule from private-connectivity; used as gcp\_vpc\_endpoint\_info.psc\_endpoint\_name | `string` | `null` | no |
| <a name="input_hub_frontend_forwarding_rule_name"></a> [hub\_frontend\_forwarding\_rule\_name](#input\_hub\_frontend\_forwarding\_rule\_name) | Name of the hub-side frontend PSC forwarding rule from private-connectivity; used as gcp\_vpc\_endpoint\_info.psc\_endpoint\_name | `string` | `null` | no |
| <a name="input_hub_vpc_google_project"></a> [hub\_vpc\_google\_project](#input\_hub\_vpc\_google\_project) | GCP project hosting the hub VPC (used for the transit databricks\_mws\_vpc\_endpoint when restricted\_egress is enabled) | `string` | `null` | no |
| <a name="input_nat_dependency"></a> [nat\_dependency](#input\_nat\_dependency) | Opaque value (typically the Cloud NAT ID) used as depends\_on for the workspace to ensure NAT readiness before workspace creation | `any` | `null` | no |
| <a name="input_private_access_only"></a> [private\_access\_only](#input\_private\_access\_only) | Create databricks\_mws\_private\_access\_settings with public\_access\_enabled=false and attach it to the workspace | `bool` | `false` | no |
| <a name="input_serverless_allowed_internet_destinations"></a> [serverless\_allowed\_internet\_destinations](#input\_serverless\_allowed\_internet\_destinations) | FQDNs serverless workloads may reach when serverless\_egress\_mode=restricted (max 100) | `list(string)` | `[]` | no |
| <a name="input_serverless_allowed_storage_destinations"></a> [serverless\_allowed\_storage\_destinations](#input\_serverless\_allowed\_storage\_destinations) | GCS bucket names serverless workloads may reach when serverless\_egress\_mode=restricted (max 100); region is taken from google\_region | `list(string)` | `[]` | no |
| <a name="input_serverless_egress_enforcement"></a> [serverless\_egress\_enforcement](#input\_serverless\_egress\_enforcement) | enforced: violations are blocked; dry\_run: violations are only logged (use to evaluate a policy before enforcing) | `string` | `"enforced"` | no |
| <a name="input_serverless_egress_mode"></a> [serverless\_egress\_mode](#input\_serverless\_egress\_mode) | Serverless egress control. unmanaged: no network policy resources; full: policy with FULL\_ACCESS; restricted: deny-by-default policy allowing only the listed destinations. Requires the workspace to be on the Enterprise tier | `string` | `"unmanaged"` | no |
| <a name="input_spoke_subnet_name"></a> [spoke\_subnet\_name](#input\_spoke\_subnet\_name) | Name of the spoke subnet used in databricks\_mws\_networks.gcp\_network\_info.subnet\_id (null when vpc\_source=databricks\_managed) | `string` | `null` | no |
| <a name="input_spoke_vpc_google_project"></a> [spoke\_vpc\_google\_project](#input\_spoke\_vpc\_google\_project) | GCP project hosting the spoke VPC (used in databricks\_mws\_networks.gcp\_network\_info.network\_project\_id) | `string` | `null` | no |
| <a name="input_spoke_vpc_name"></a> [spoke\_vpc\_name](#input\_spoke\_vpc\_name) | Name of the spoke VPC used in databricks\_mws\_networks.gcp\_network\_info.vpc\_id (null when vpc\_source=databricks\_managed) | `string` | `null` | no |
| <a name="input_workspace_name"></a> [workspace\_name](#input\_workspace\_name) | Optional workspace name override. Defaults to "prefix-ws-suffix" when null | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backend_endpoint_id"></a> [backend\_endpoint\_id](#output\_backend\_endpoint\_id) | Backend mws\_vpc\_endpoint ID (null when no PSC) |
| <a name="output_frontend_endpoint_id"></a> [frontend\_endpoint\_id](#output\_frontend\_endpoint\_id) | Frontend mws\_vpc\_endpoint ID (null when no PSC) |
| <a name="output_network_id"></a> [network\_id](#output\_network\_id) | mws\_networks ID (null when databricks\_managed) |
| <a name="output_private_access_settings_id"></a> [private\_access\_settings\_id](#output\_private\_access\_settings\_id) | databricks\_mws\_private\_access\_settings ID (null when private\_access\_only=false) |
| <a name="output_serverless_network_policy_id"></a> [serverless\_network\_policy\_id](#output\_serverless\_network\_policy\_id) | Serverless egress network-policy ID bound to the workspace (null when serverless\_egress\_mode=unmanaged) |
| <a name="output_transit_endpoint_id"></a> [transit\_endpoint\_id](#output\_transit\_endpoint\_id) | Hub-side mws\_vpc\_endpoint ID (null when no hub) |
| <a name="output_workspace_id"></a> [workspace\_id](#output\_workspace\_id) | Databricks workspace ID |
| <a name="output_workspace_url"></a> [workspace\_url](#output\_workspace\_url) | Databricks workspace URL |
<!-- END_TF_DOCS -->
