# modules/gcp/dns

Private DNS zones (hub + spoke) used with restricted-egress workspaces.

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
| [google_dns_managed_zone.gcr](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_managed_zone) | resource |
| [google_dns_managed_zone.google_apis](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_managed_zone) | resource |
| [google_dns_managed_zone.hub_dbx](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_managed_zone) | resource |
| [google_dns_managed_zone.pkg_dev](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_managed_zone) | resource |
| [google_dns_managed_zone.spoke_dbx](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_managed_zone) | resource |
| [google_dns_record_set.gcr_a](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set) | resource |
| [google_dns_record_set.gcr_cname](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set) | resource |
| [google_dns_record_set.google_apis_a](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set) | resource |
| [google_dns_record_set.google_apis_cname](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set) | resource |
| [google_dns_record_set.hub_dp](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set) | resource |
| [google_dns_record_set.hub_psc_auth](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set) | resource |
| [google_dns_record_set.hub_workspace_url](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set) | resource |
| [google_dns_record_set.pkg_dev_a](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set) | resource |
| [google_dns_record_set.pkg_dev_cname](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set) | resource |
| [google_dns_record_set.spoke_dp](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set) | resource |
| [google_dns_record_set.spoke_tunnel](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set) | resource |
| [google_dns_record_set.spoke_workspace_url](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backend_psc_ip_spoke"></a> [backend\_psc\_ip\_spoke](#input\_backend\_psc\_ip\_spoke) | n/a | `string` | n/a | yes |
| <a name="input_frontend_psc_ip_spoke"></a> [frontend\_psc\_ip\_spoke](#input\_frontend\_psc\_ip\_spoke) | PSC IPs | `string` | n/a | yes |
| <a name="input_google_region"></a> [google\_region](#input\_google\_region) | n/a | `string` | n/a | yes |
| <a name="input_hub_vpc_google_project"></a> [hub\_vpc\_google\_project](#input\_hub\_vpc\_google\_project) | n/a | `string` | n/a | yes |
| <a name="input_hub_vpc_id"></a> [hub\_vpc\_id](#input\_hub\_vpc\_id) | Hub | `string` | n/a | yes |
| <a name="input_hub_vpc_self_link"></a> [hub\_vpc\_self\_link](#input\_hub\_vpc\_self\_link) | n/a | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | n/a | `string` | n/a | yes |
| <a name="input_spoke_vpc_google_project"></a> [spoke\_vpc\_google\_project](#input\_spoke\_vpc\_google\_project) | n/a | `string` | n/a | yes |
| <a name="input_spoke_vpc_id"></a> [spoke\_vpc\_id](#input\_spoke\_vpc\_id) | Spoke | `string` | n/a | yes |
| <a name="input_spoke_vpc_self_link"></a> [spoke\_vpc\_self\_link](#input\_spoke\_vpc\_self\_link) | n/a | `string` | n/a | yes |
| <a name="input_workspace_url"></a> [workspace\_url](#input\_workspace\_url) | Workspace | `string` | n/a | yes |
| <a name="input_frontend_psc_ip_hub"></a> [frontend\_psc\_ip\_hub](#input\_frontend\_psc\_ip\_hub) | n/a | `string` | `null` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
