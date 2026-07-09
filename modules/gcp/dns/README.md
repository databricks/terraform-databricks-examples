# modules/gcp/dns

Private DNS zones (hub + spoke) used with restricted-egress workspaces.

## Usage

Typically called by `modules/gcp/databricks-workspace` (the composer) when `restricted_egress=true`. Direct consumption is unusual; this module is terminal (no outputs).

```hcl
module "dns" {
  source = "github.com/databricks/terraform-databricks-examples//modules/gcp/dns"

  prefix        = "acme"
  google_region = "us-central1"

  hub_vpc_id             = module.network.hub_vpc_id
  hub_vpc_self_link      = module.network.hub_vpc_self_link
  hub_vpc_google_project = "my-hub-project"

  spoke_vpc_id             = module.network.spoke_vpc_id
  spoke_vpc_self_link      = module.network.spoke_vpc_self_link
  spoke_vpc_google_project = "my-spoke-project"

  workspace_url = module.workspace.workspace_url

  frontend_psc_ip_spoke = module.private_connectivity.frontend_psc_ip_spoke
  frontend_psc_ip_hub   = module.private_connectivity.frontend_psc_ip_hub
  backend_psc_ip_spoke  = module.private_connectivity.backend_psc_ip_spoke
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
| [google_dns_managed_zone.gcr](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_managed_zone) | resource |
| [google_dns_managed_zone.google_apis](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_managed_zone) | resource |
| [google_dns_managed_zone.hub_databricks](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_managed_zone) | resource |
| [google_dns_managed_zone.pkg_dev](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_managed_zone) | resource |
| [google_dns_managed_zone.spoke_databricks](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_managed_zone) | resource |
| [google_dns_managed_zone.spoke_peering_gcr](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_managed_zone) | resource |
| [google_dns_managed_zone.spoke_peering_google_apis](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_managed_zone) | resource |
| [google_dns_managed_zone.spoke_peering_pkg_dev](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_managed_zone) | resource |
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
| <a name="input_backend_psc_ip_spoke"></a> [backend\_psc\_ip\_spoke](#input\_backend\_psc\_ip\_spoke) | Spoke-side backend (SCC) PSC endpoint IP (used in the spoke tunnel.<region>.gcp.databricks.com A record) | `string` | n/a | yes |
| <a name="input_frontend_psc_ip_spoke"></a> [frontend\_psc\_ip\_spoke](#input\_frontend\_psc\_ip\_spoke) | Spoke-side frontend PSC endpoint IP (used in the spoke gcp.databricks.com A records) | `string` | n/a | yes |
| <a name="input_google_region"></a> [google\_region](#input\_google\_region) | GCP region (used in the spoke tunnel DNS record name) | `string` | n/a | yes |
| <a name="input_hub_vpc_google_project"></a> [hub\_vpc\_google\_project](#input\_hub\_vpc\_google\_project) | GCP project hosting the hub VPC (used for the hub DNS zones) | `string` | n/a | yes |
| <a name="input_hub_vpc_id"></a> [hub\_vpc\_id](#input\_hub\_vpc\_id) | ID of the hub VPC (DNS zones with this VPC's visibility) | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix used to name generated DNS managed zones | `string` | n/a | yes |
| <a name="input_spoke_vpc_google_project"></a> [spoke\_vpc\_google\_project](#input\_spoke\_vpc\_google\_project) | GCP project hosting the spoke VPC (used for the spoke DNS zone) | `string` | n/a | yes |
| <a name="input_spoke_vpc_id"></a> [spoke\_vpc\_id](#input\_spoke\_vpc\_id) | ID of the spoke VPC (DNS zone with this VPC's visibility) | `string` | n/a | yes |
| <a name="input_workspace_url"></a> [workspace\_url](#input\_workspace\_url) | Workspace URL from databricks\_mws\_workspaces; used to extract the workspace DNS ID via regex | `string` | n/a | yes |
| <a name="input_frontend_psc_ip_hub"></a> [frontend\_psc\_ip\_hub](#input\_frontend\_psc\_ip\_hub) | Hub-side frontend PSC endpoint IP (used in the hub gcp.databricks.com A records) | `string` | `null` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
