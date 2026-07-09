# Cross-Cloud Module Contract

Normative conventions for `modules/<cloud>/` in this repository. The GCP tree
is the reference implementation (PR #233). Azure and AWS refactors are
reviewed against this document.

## 1. Module slots

Every cloud provides these modules, defined by responsibility:

| Slot | Responsibility | GCP | Azure (dialect) | AWS (dialect) |
|---|---|---|---|---|
| `network` | Data-plane network: create or look up VPC/VNet, subnets, NAT, hub-spoke peering, shared-network bindings | `modules/gcp/network` | VNet + subnets + NSGs | VPC + subnets + NAT |
| `private-connectivity` | Private endpoints to the Databricks control plane + egress firewall stack | PSC endpoints | Private Endpoints | VPC endpoints (PrivateLink) |
| `workspace` | Everything registering the workspace with the Databricks control plane | `databricks_mws_*` | `azurerm_databricks_workspace` + access connector | `databricks_mws_*` |
| `dns` | Private DNS zones/records for the private endpoints | Cloud DNS private + peering zones | Private DNS zones | Route 53 private hosted zones |
| `databricks-workspace` | Composer: takes scenario flags, conditionally instantiates the slots (`network → private-connectivity → workspace → dns`) | done | future | future |
| `serverless-connectivity` (reserved) | NCC: serverless private connectivity to customer resources | pending GCP release (near Public Preview, Jul 2026) | `databricks_mws_network_connectivity_config` | same |

Cloud-neutral modules (identical resources on every cloud) live under
`modules/databricks/` (first resident: `security-settings`).

## 2. Frozen interface (identical names on every cloud)

Composer variables: `prefix`, `workspace_name`, `databricks_account_id`,
`tags`; `private_link_frontend`, `private_link_backend`,
`private_access_only`, `restricted_egress`; `serverless_egress_mode`
(`unmanaged|full|restricted`), `serverless_allowed_internet_destinations`,
`serverless_allowed_storage_destinations`, `serverless_egress_enforcement`
(`enforced|dry_run`); `cmek_managed_services_key_id`, `cmek_storage_key_id`
(the key-reference format is per-cloud).

The network-source variable uses the cloud's noun (`vpc_source` /
`vnet_source`) but its values are frozen:
`databricks_managed | create | existing`.

Composer outputs: `workspace_id`, `workspace_url`, `suffix`,
`serverless_network_policy_id`, plus per-cloud network outputs following the
noun table.

Cloud dialect constraints are allowed where the platform demands them and
must be enforced as preconditions with an explanatory error message (GCP:
`private_link_frontend == private_link_backend`, because
`mws_networks.vpc_endpoints` requires both endpoint references).

## 3. Two-tier naming

Tier 1 (frozen): everything in section 2, plus the vocabulary `hub`/`spoke`
and `frontend`/`backend`.

Tier 2 (native nouns): each cloud names cloud objects with its own noun.

| Concept | GCP | Azure | AWS |
|---|---|---|---|
| Network | `*_vpc_*` | `*_vnet_*` | `*_vpc_*` |
| Private endpoint mechanism | `psc` | `private_endpoint` | `vpc_endpoint` |
| Region | `google_region` | `azure_region` | `aws_region` |
| Resource container | `google_project` | `azure_resource_group` | (account-level, none) |
| Endpoint subnet | `psc_subnet_cidr` | `private_endpoint_subnet_cidr` | `endpoint_subnet_cidrs` |
| Endpoint IP outputs | `frontend_psc_ip_<spoke\|hub>` | `frontend_endpoint_ip_<spoke\|hub>` | n/a (ENI-based) |

## 4. File shape

Modules: one concern per `.tf` file; `versions.tf` declares
`required_version` + `required_providers` floors only (`google >= 6.0`,
`databricks >= 1.81.1`, `random >= 3.0`); no `provider {}` blocks.
Examples: `versions.tf` (pessimistic pins `~> 6.17` / `~> 1.81`) +
`providers.tf` + `main.tf` + `variables.tf` + `outputs.tf` +
`terraform.tfvars` + `README.md` + `Makefile`.

Every variable and output has a `description`. Module READMEs carry a
`## Usage` HCL block above the terraform-docs markers.

## 5. Validation & testing standard

- Cross-variable rules live in the composer's `preconditions.tf` on a
  `terraform_data` resource; the PR description documents the rule table.
- `count`/`for_each` must never depend on apply-time values.
- Each composer scenario has a positive fixture under `tests/<scenario>/`
  that completes `terraform plan` offline; preconditions are covered by
  `tests/negative-*` fixtures that fail plan with the expected message (at
  minimum, every rule that guards a scenario flag combination).
- Submodules carry per-scenario plan fixtures.
