# modules/gcp/network

VPC, subnet, router, NAT, peering, and Shared-VPC binding for the Databricks GCP composer.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 6.46.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_network.hub_vpc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_network.spoke_vpc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_network_peering.hub_to_spoke](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_peering) | resource |
| [google_compute_network_peering.spoke_to_hub](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_peering) | resource |
| [google_compute_router.router](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router) | resource |
| [google_compute_router_nat.nat](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat) | resource |
| [google_compute_shared_vpc_host_project.host](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_shared_vpc_host_project) | resource |
| [google_compute_shared_vpc_service_project.service](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_shared_vpc_service_project) | resource |
| [google_compute_subnetwork.hub_subnet](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_compute_subnetwork.spoke_subnet](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_compute_network.existing_spoke](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_network) | data source |
| [google_compute_subnetwork.existing_spoke_subnet](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_subnetwork) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_google_region"></a> [google\_region](#input\_google\_region) | GCP region for all network resources | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix for generated resource names | `string` | n/a | yes |
| <a name="input_spoke_vpc_google_project"></a> [spoke\_vpc\_google\_project](#input\_spoke\_vpc\_google\_project) | GCP project hosting the spoke VPC | `string` | n/a | yes |
| <a name="input_suffix"></a> [suffix](#input\_suffix) | Random suffix passed by the composer for uniqueness | `string` | n/a | yes |
| <a name="input_vpc_source"></a> [vpc\_source](#input\_vpc\_source) | Either 'create' (Terraform creates a VPC) or 'existing' (data-source lookup) | `string` | n/a | yes |
| <a name="input_create_hub"></a> [create\_hub](#input\_create\_hub) | Create a hub VPC + subnet + peering with the spoke. Composer passes restricted\_egress here. | `bool` | `false` | no |
| <a name="input_existing_subnet_name"></a> [existing\_subnet\_name](#input\_existing\_subnet\_name) | Name of pre-existing subnet (required when vpc\_source=existing) | `string` | `null` | no |
| <a name="input_existing_vpc_name"></a> [existing\_vpc\_name](#input\_existing\_vpc\_name) | Name of pre-existing VPC (required when vpc\_source=existing) | `string` | `null` | no |
| <a name="input_hub_vpc_cidr"></a> [hub\_vpc\_cidr](#input\_hub\_vpc\_cidr) | CIDR for the hub subnet (required when create\_hub=true) | `string` | `null` | no |
| <a name="input_hub_vpc_google_project"></a> [hub\_vpc\_google\_project](#input\_hub\_vpc\_google\_project) | GCP project hosting the hub VPC (required when create\_hub=true) | `string` | `null` | no |
| <a name="input_is_spoke_vpc_shared"></a> [is\_spoke\_vpc\_shared](#input\_is\_spoke\_vpc\_shared) | If true, bind the spoke VPC's project as a Shared-VPC host and the workspace project as a service project | `bool` | `false` | no |
| <a name="input_pod_cidr"></a> [pod\_cidr](#input\_pod\_cidr) | GKE secondary range for pods (optional) | `string` | `null` | no |
| <a name="input_spoke_vpc_cidr"></a> [spoke\_vpc\_cidr](#input\_spoke\_vpc\_cidr) | CIDR for the spoke subnet primary range (required when vpc\_source=create) | `string` | `null` | no |
| <a name="input_subnet_cidr"></a> [subnet\_cidr](#input\_subnet\_cidr) | CIDR for the spoke subnet (required when vpc\_source=create) | `string` | `null` | no |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | Override for spoke subnet name (default: "{prefix}-subnet-{suffix}") | `string` | `null` | no |
| <a name="input_svc_cidr"></a> [svc\_cidr](#input\_svc\_cidr) | GKE secondary range for services (optional) | `string` | `null` | no |
| <a name="input_workspace_google_project"></a> [workspace\_google\_project](#input\_workspace\_google\_project) | Workspace project (used for Shared-VPC service binding) | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_hub_subnet_name"></a> [hub\_subnet\_name](#output\_hub\_subnet\_name) | Name of the hub subnet (null when create\_hub=false) |
| <a name="output_hub_vpc_id"></a> [hub\_vpc\_id](#output\_hub\_vpc\_id) | ID of the hub VPC (null when create\_hub=false) |
| <a name="output_hub_vpc_name"></a> [hub\_vpc\_name](#output\_hub\_vpc\_name) | Name of the hub VPC (null when create\_hub=false) |
| <a name="output_hub_vpc_self_link"></a> [hub\_vpc\_self\_link](#output\_hub\_vpc\_self\_link) | Self-link of the hub VPC (null when create\_hub=false) |
| <a name="output_nat_id"></a> [nat\_id](#output\_nat\_id) | ID of the Cloud NAT (null when vpc\_source=existing) |
| <a name="output_spoke_subnet_id"></a> [spoke\_subnet\_id](#output\_spoke\_subnet\_id) | ID of the spoke subnet |
| <a name="output_spoke_subnet_name"></a> [spoke\_subnet\_name](#output\_spoke\_subnet\_name) | Name of the spoke subnet |
| <a name="output_spoke_subnet_self_link"></a> [spoke\_subnet\_self\_link](#output\_spoke\_subnet\_self\_link) | Self-link of the spoke subnet |
| <a name="output_spoke_vpc_id"></a> [spoke\_vpc\_id](#output\_spoke\_vpc\_id) | ID of the spoke VPC |
| <a name="output_spoke_vpc_name"></a> [spoke\_vpc\_name](#output\_spoke\_vpc\_name) | Name of the spoke VPC |
| <a name="output_spoke_vpc_self_link"></a> [spoke\_vpc\_self\_link](#output\_spoke\_vpc\_self\_link) | Self-link of the spoke VPC |
<!-- END_TF_DOCS -->
