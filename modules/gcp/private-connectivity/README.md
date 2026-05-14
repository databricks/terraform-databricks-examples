# modules/gcp/private-connectivity

GCP-side PSC endpoints + restricted-egress firewall for the Databricks GCP composer.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 7.31.0 |

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
| [google_compute_forwarding_rule.backend_fr](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule) | resource |
| [google_compute_forwarding_rule.frontend_fr_hub](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule) | resource |
| [google_compute_forwarding_rule.frontend_fr_spoke](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule) | resource |
| [google_compute_subnetwork.psc_subnet](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_google_region"></a> [google\_region](#input\_google\_region) | n/a | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | n/a | `string` | n/a | yes |
| <a name="input_psc_subnet_cidr"></a> [psc\_subnet\_cidr](#input\_psc\_subnet\_cidr) | CIDR for the dedicated PSC subnet in the spoke VPC | `string` | n/a | yes |
| <a name="input_spoke_vpc_cidr"></a> [spoke\_vpc\_cidr](#input\_spoke\_vpc\_cidr) | n/a | `string` | n/a | yes |
| <a name="input_spoke_vpc_google_project"></a> [spoke\_vpc\_google\_project](#input\_spoke\_vpc\_google\_project) | n/a | `string` | n/a | yes |
| <a name="input_spoke_vpc_id"></a> [spoke\_vpc\_id](#input\_spoke\_vpc\_id) | Spoke network refs | `string` | n/a | yes |
| <a name="input_spoke_vpc_self_link"></a> [spoke\_vpc\_self\_link](#input\_spoke\_vpc\_self\_link) | n/a | `string` | n/a | yes |
| <a name="input_suffix"></a> [suffix](#input\_suffix) | n/a | `string` | n/a | yes |
| <a name="input_enable_backend"></a> [enable\_backend](#input\_enable\_backend) | n/a | `bool` | `false` | no |
| <a name="input_enable_frontend"></a> [enable\_frontend](#input\_enable\_frontend) | Feature flags | `bool` | `false` | no |
| <a name="input_hive_metastore_ip"></a> [hive\_metastore\_ip](#input\_hive\_metastore\_ip) | Regional Hive metastore IP (looked up via internal map if null) | `string` | `null` | no |
| <a name="input_hub_subnet_name"></a> [hub\_subnet\_name](#input\_hub\_subnet\_name) | n/a | `string` | `null` | no |
| <a name="input_hub_vpc_cidr"></a> [hub\_vpc\_cidr](#input\_hub\_vpc\_cidr) | n/a | `string` | `null` | no |
| <a name="input_hub_vpc_google_project"></a> [hub\_vpc\_google\_project](#input\_hub\_vpc\_google\_project) | n/a | `string` | `null` | no |
| <a name="input_hub_vpc_id"></a> [hub\_vpc\_id](#input\_hub\_vpc\_id) | Hub network refs (nullable when no hub) | `string` | `null` | no |
| <a name="input_hub_vpc_self_link"></a> [hub\_vpc\_self\_link](#input\_hub\_vpc\_self\_link) | n/a | `string` | `null` | no |
| <a name="input_restrict_egress"></a> [restrict\_egress](#input\_restrict\_egress) | n/a | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backend_psc_fr_id"></a> [backend\_psc\_fr\_id](#output\_backend\_psc\_fr\_id) | Name of the backend (SCC) PSC forwarding rule (null when enable\_backend=false) |
| <a name="output_backend_psc_ip_spoke"></a> [backend\_psc\_ip\_spoke](#output\_backend\_psc\_ip\_spoke) | IP address of the spoke-side backend PSC endpoint |
| <a name="output_frontend_psc_fr_id"></a> [frontend\_psc\_fr\_id](#output\_frontend\_psc\_fr\_id) | Name of the frontend PSC forwarding rule (null when enable\_frontend=false) |
| <a name="output_frontend_psc_ip_hub"></a> [frontend\_psc\_ip\_hub](#output\_frontend\_psc\_ip\_hub) | IP address of the hub-side frontend PSC endpoint (null when no hub) |
| <a name="output_frontend_psc_ip_spoke"></a> [frontend\_psc\_ip\_spoke](#output\_frontend\_psc\_ip\_spoke) | IP address of the spoke-side frontend PSC endpoint |
| <a name="output_hub_frontend_psc_fr_id"></a> [hub\_frontend\_psc\_fr\_id](#output\_hub\_frontend\_psc\_fr\_id) | Name of the hub-side frontend PSC forwarding rule (null when no hub or no frontend) |
| <a name="output_psc_subnet_self_link"></a> [psc\_subnet\_self\_link](#output\_psc\_subnet\_self\_link) | Self-link of the PSC subnet |
<!-- END_TF_DOCS -->
