# modules/gcp/private-connectivity

GCP-side PSC endpoints + restricted-egress firewall for the Databricks GCP composer.

## Usage

Typically called by `modules/gcp/databricks-workspace` (the composer). Direct consumption is supported but unusual.

```hcl
module "private_connectivity" {
  source = "github.com/databricks/terraform-databricks-examples//modules/gcp/private-connectivity"

  prefix        = "acme"
  suffix        = "abc123"
  google_region = "us-central1"

  spoke_vpc_id             = module.network.spoke_vpc_id
  spoke_vpc_self_link      = module.network.spoke_vpc_self_link
  spoke_vpc_google_project = "my-spoke-project"
  spoke_vpc_cidr           = "10.0.0.0/16"

  enable_frontend = true
  enable_backend  = true
  psc_subnet_cidr = "10.0.255.0/28"
}
```

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
| [google_compute_address.backend_address](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_address.frontend_address_hub](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_address.frontend_address_spoke](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_firewall.hub_ingress](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.spoke_allow_ctl_plane](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.spoke_allow_google_apis](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.spoke_allow_hive](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.spoke_default_deny_egress](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.spoke_intra_egress](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.spoke_intra_ingress](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_forwarding_rule.backend_fr](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule) | resource |
| [google_compute_forwarding_rule.frontend_fr_hub](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule) | resource |
| [google_compute_forwarding_rule.frontend_fr_spoke](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule) | resource |
| [google_compute_subnetwork.psc_subnet](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_google_region"></a> [google\_region](#input\_google\_region) | GCP region for PSC and firewall resources (must be one of the regions in the regional PSC service-attachment maps) | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix used to name generated resources | `string` | n/a | yes |
| <a name="input_psc_subnet_cidr"></a> [psc\_subnet\_cidr](#input\_psc\_subnet\_cidr) | CIDR for the dedicated PSC subnet in the spoke VPC | `string` | n/a | yes |
| <a name="input_spoke_vpc_cidr"></a> [spoke\_vpc\_cidr](#input\_spoke\_vpc\_cidr) | CIDR of the spoke VPC address space (used as source\_ranges for the hub ingress firewall) | `string` | n/a | yes |
| <a name="input_spoke_vpc_google_project"></a> [spoke\_vpc\_google\_project](#input\_spoke\_vpc\_google\_project) | GCP project that hosts the spoke VPC | `string` | n/a | yes |
| <a name="input_spoke_vpc_id"></a> [spoke\_vpc\_id](#input\_spoke\_vpc\_id) | ID of the spoke VPC (output from the network module) | `string` | n/a | yes |
| <a name="input_spoke_vpc_self_link"></a> [spoke\_vpc\_self\_link](#input\_spoke\_vpc\_self\_link) | Self-link of the spoke VPC (used as the network reference for firewall rules) | `string` | n/a | yes |
| <a name="input_suffix"></a> [suffix](#input\_suffix) | Random suffix appended to resource names for uniqueness (passed by the composer) | `string` | n/a | yes |
| <a name="input_create_hub"></a> [create\_hub](#input\_create\_hub) | Whether the hub VPC exists (composer passes restricted\_egress). Gates hub-side PSC and firewall resources; must be plan-time static | `bool` | `false` | no |
| <a name="input_enable_backend"></a> [enable\_backend](#input\_enable\_backend) | Create the backend (SCC, data plane) PSC endpoint on the spoke | `bool` | `false` | no |
| <a name="input_enable_frontend"></a> [enable\_frontend](#input\_enable\_frontend) | Create the frontend (workspace UI/API) PSC endpoint on the spoke and, if hub exists, the hub side | `bool` | `false` | no |
| <a name="input_hive_metastore_ip"></a> [hive\_metastore\_ip](#input\_hive\_metastore\_ip) | Regional legacy Hive metastore IP. When set, an egress allow rule (tcp/3306) is created under restricted egress; when null, no rule is created. Workspaces using Unity Catalog (the default) do not need this. Regional IPs: https://docs.databricks.com/gcp/en/resources/ip-domain-region | `string` | `null` | no |
| <a name="input_hub_subnet_name"></a> [hub\_subnet\_name](#input\_hub\_subnet\_name) | Name of the hub subnet (used as the subnetwork reference for the hub-side PSC address) | `string` | `null` | no |
| <a name="input_hub_vpc_google_project"></a> [hub\_vpc\_google\_project](#input\_hub\_vpc\_google\_project) | GCP project that hosts the hub VPC (null when no hub is created) | `string` | `null` | no |
| <a name="input_hub_vpc_id"></a> [hub\_vpc\_id](#input\_hub\_vpc\_id) | ID of the hub VPC (null when no hub is created) | `string` | `null` | no |
| <a name="input_hub_vpc_self_link"></a> [hub\_vpc\_self\_link](#input\_hub\_vpc\_self\_link) | Self-link of the hub VPC (null when no hub is created) | `string` | `null` | no |
| <a name="input_restrict_egress"></a> [restrict\_egress](#input\_restrict\_egress) | Create the egress firewall stack: deny-egress, allow Google APIs, allow control plane, allow managed Hive (conditional), hub ingress | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backend_forwarding_rule_name"></a> [backend\_forwarding\_rule\_name](#output\_backend\_forwarding\_rule\_name) | Name of the backend (SCC) PSC forwarding rule (null when enable\_backend=false) |
| <a name="output_backend_psc_ip_spoke"></a> [backend\_psc\_ip\_spoke](#output\_backend\_psc\_ip\_spoke) | IP address of the spoke-side backend PSC endpoint |
| <a name="output_frontend_forwarding_rule_name"></a> [frontend\_forwarding\_rule\_name](#output\_frontend\_forwarding\_rule\_name) | Name of the spoke-side frontend PSC forwarding rule (null when enable\_frontend=false) |
| <a name="output_frontend_psc_ip_hub"></a> [frontend\_psc\_ip\_hub](#output\_frontend\_psc\_ip\_hub) | IP address of the hub-side frontend PSC endpoint (null when no hub) |
| <a name="output_frontend_psc_ip_spoke"></a> [frontend\_psc\_ip\_spoke](#output\_frontend\_psc\_ip\_spoke) | IP address of the spoke-side frontend PSC endpoint |
| <a name="output_hub_frontend_forwarding_rule_name"></a> [hub\_frontend\_forwarding\_rule\_name](#output\_hub\_frontend\_forwarding\_rule\_name) | Name of the hub-side frontend PSC forwarding rule (null when no hub or no frontend) |
| <a name="output_psc_subnet_self_link"></a> [psc\_subnet\_self\_link](#output\_psc\_subnet\_self\_link) | Self-link of the PSC subnet |
<!-- END_TF_DOCS -->
