# GCP Modules Best-Practices Refactor — Design Spec

**Date:** 2026-05-26
**Author:** Michele Daddetta
**Status:** Approved (pending implementation plan)
**Branch:** `feature/gcp-modules-refactor` (continues on the existing draft PR #233)

## Problem

The GCP composer + submodules landed in PR #233 work correctly but their internal organization and metadata are uneven. Concrete gaps surfaced during audit:

- **Variable description coverage is dramatically uneven across modules:** `network` has 17/17 documented, but `private-connectivity` has 2/17, `account` has 1/18, `dns` has 0/12, `databricks-workspace` (composer) has 1/23. Roughly 70 variables ship without descriptions, which means the auto-generated terraform-docs READMEs are unusable as reference material and IDE hovers show nothing.
- **File organization is inconsistent.** `network/main.tf` is 131 lines mixing five concerns (spoke VPC, hub VPC, peering, shared-VPC, data sources). `account/main.tf` mixes locals + workspace + networks resources. `databricks-workspace/main.tf` (the composer) mixes locals + suffix + preconditions + module wirings (149 lines).
- **Provider/versions placement is inconsistent.** Most modules use `versions.tf`, but `service-account` uses `init.tf` (which also illegally contains `provider "google" {}` — modules must not configure providers), and `unity-catalog` uses `terraform.tf`. Examples are equally inconsistent: `gcp-basic` and three other examples use a combined `init.tf`; the PSC example splits across `terraform.tf` + `providers.tf`.
- **Output completeness gaps on the composer.** Missing: `subnet_id`/`self_link`, hub VPC `self_link`, NAT id, `private_access_settings_id`, the three `mws_vpc_endpoint` IDs, and the three PSC IPs. Has redundancy: `vpc_id` is identical to `spoke_vpc_id`. Uses `try(module.network[0].*, null)` which works but hides intent compared to an explicit `local.databricks_managed ? null : module.network[0].*` ternary.
- **Output naming misnomers.** Outputs named `*_psc_fr_id` return GCP forwarding-rule **names**, not IDs (the underlying attribute is `google_compute_forwarding_rule.x.name`). Same misnomer in the `account` module's input variables.
- **Module READMEs are placeholder-plus-terraform-docs only.** No `## Usage` HCL block. terraform-google-modules and HashiCorp registry convention is to include a minimal calling example above the auto-generated section.
- **No regional validation.** The `private-connectivity` module hardcodes regional PSC service-attachment maps for 14 regions but accepts any string for `google_region` — invalid regions fail with a confusing map-lookup error instead of a clear validation message.

## Goals

1. Every variable in every module has a `description`.
2. Each module's `.tf` files have one clear concern each; no file mixes three or more responsibilities.
3. Every module declares only `terraform { required_providers + required_version }` in a file named `versions.tf`. No provider configuration blocks inside modules.
4. Every example has the same file shape: `versions.tf` (required_providers) + `providers.tf` (provider blocks) + `main.tf` + `variables.tf` + `outputs.tf` + `terraform.tfvars` + `README.md` + `Makefile`.
5. Composer outputs cover everything a downstream consumer might want, with explicit conditional ternaries instead of `try()`.
6. Output and variable names are accurate (no `*_fr_id` for things that are names; no aliases like `vpc_id` shadowing `spoke_vpc_id`).
7. `google_region` is validated against the supported-region list at the boundary where the regional maps actually live.
8. Each module README has a `## Usage` block before the terraform-docs section.

## Non-Goals

- No behavioral changes to the composer's runtime logic (preconditions stay; module wiring stays; resource attributes stay).
- No new submodules; no rename of any module directory.
- No CIDR or IP-format validation (GCP API rejects bad CIDRs with clear errors; relying on that is fine).
- No `tags` propagation across resources. The unused `tags` variable on the composer is documented as reserved-for-future and otherwise left alone (the user explicitly opted out of removing or propagating it).
- No new tests beyond keeping the existing fixtures passing.
- No changes to AWS or Azure modules/examples.

## Scope of changes

### Modules under `modules/gcp/`

**`network/`** (4 → 10 .tf files):

| File | Contents |
|------|----------|
| `vpc.tf` | `google_compute_network.spoke_vpc`, `google_compute_network.hub_vpc` |
| `subnets.tf` | `google_compute_subnetwork.spoke_subnet`, `google_compute_subnetwork.hub_subnet` |
| `nat.tf` | `google_compute_router.router`, `google_compute_router_nat.nat` |
| `peering.tf` | both `google_compute_network_peering` resources |
| `shared-vpc.tf` | `google_compute_shared_vpc_host_project`, `google_compute_shared_vpc_service_project` |
| `data.tf` | data sources for existing-vpc lookups |
| `locals.tf` | `create_vpc`, `use_existing_vpc`, `subnet_name` (moved from `main.tf`) |
| `variables.tf` | unchanged (all 17 already documented) |
| `outputs.tf` | unchanged |
| `versions.tf` | unchanged |

`main.tf` is removed (its contents redistribute).

**`private-connectivity/`** (file layout unchanged; the `psc.tf` + `firewall.tf` + `locals.tf` split is already good):

- `variables.tf`: add `description` to the 15 undocumented variables
- `outputs.tf`: rename `frontend_psc_fr_id` → `frontend_forwarding_rule_name`, `backend_psc_fr_id` → `backend_forwarding_rule_name`, `hub_frontend_psc_fr_id` → `hub_frontend_forwarding_rule_name`
- `variables.tf`: add `validation { contains(<14 regions>, var.google_region) }` on `google_region`
- `README.md`: add `## Usage` block

**`account/`** (6 → 8 .tf files):

| File | Contents |
|------|----------|
| `workspace.tf` | `databricks_mws_workspaces.this` (moved from `main.tf`) |
| `networks.tf` | `databricks_mws_networks.this` (moved from `main.tf`) |
| `vpc-endpoints.tf` | unchanged |
| `pas.tf` | unchanged (kept short — 9 lines, single resource, doesn't justify merging) |
| `locals.tf` | the 4 locals from `main.tf` |
| `variables.tf` | add descriptions to 17 variables; rename inputs `frontend_psc_fr_id`/`backend_psc_fr_id`/`hub_frontend_psc_fr_id` → `frontend_forwarding_rule_name` etc. |
| `outputs.tf` | add `private_access_settings_id` output |
| `versions.tf` | unchanged |

`main.tf` is removed.

**`dns/`** (file layout unchanged; `hub.tf` + `spoke.tf` is already good):

- `locals.tf` (NEW): extract `workspace_dns_id = regex(...)` from `hub.tf`
- `variables.tf`: add descriptions to all 12 variables
- `README.md`: add `## Usage` block

**`databricks-workspace/` (composer)** (4 → 7 .tf files):

| File | Contents |
|------|----------|
| `main.tf` | only the 4 module blocks (network, private-connectivity, account, dns) |
| `locals.tf` | `databricks_managed`, `create_vpc`, `any_private_link`, `spoke_project` |
| `preconditions.tf` | `null_resource.preconditions` with 6 existing rules + 1 new region-validation rule |
| `random.tf` | `random_string.suffix` |
| `variables.tf` | add descriptions to 22 undocumented variables; `tags` documented as reserved |
| `outputs.tf` | full rewrite (see below) |
| `versions.tf` | unchanged |

**`service-account/`**:

- `init.tf` is split: `terraform {}` block moves to `versions.tf`; `provider "google" {}` is removed (modules must not configure providers; the consumer already configures it)
- `variables.tf`: add descriptions if any are missing
- `README.md`: add `## Usage` block

**`unity-catalog/`**:

- `terraform.tf` is renamed `versions.tf`
- `variables.tf`: add descriptions if any are missing (most already have them)
- `README.md`: add `## Usage` block (replaces the existing placeholder)

### Examples under `examples/`

Every example normalizes to:

```
versions.tf      # terraform { required_providers + required_version }
providers.tf     # provider "google" {} + provider "databricks" {} (+ workspace alias where used)
main.tf          # module "workspace" {}
variables.tf
outputs.tf
terraform.tfvars
README.md
Makefile
```

Per-example changes:
- `gcp-basic`: split `init.tf` → `versions.tf` + `providers.tf`
- `gcp-byovpc`: split `init.tf` → `versions.tf` + `providers.tf`
- `gcp-existing-vpc`: split `init.tf` → `versions.tf` + `providers.tf`
- `gcp-with-psc-exfiltration-protection`: rename `terraform.tf` → `versions.tf` (`providers.tf` already exists)
- `gcp-sa-provisioning`: split `init.tf` → `versions.tf` + `providers.tf`. The `provider "google" {}` block that the module currently carries is moved here (it's the natural consumer location).

## Output changes (composer)

### Removed

- `vpc_id` (alias of `spoke_vpc_id`; pure redundancy)

### Renamed (in submodules; composer doesn't expose these forwarding-rule outputs)

- `private-connectivity`: `frontend_psc_fr_id` → `frontend_forwarding_rule_name`, `backend_psc_fr_id` → `backend_forwarding_rule_name`, `hub_frontend_psc_fr_id` → `hub_frontend_forwarding_rule_name`

### Added (composer outputs)

- `private_access_settings_id`
- `frontend_endpoint_id`, `backend_endpoint_id`, `transit_endpoint_id` (the three `mws_vpc_endpoint` IDs)
- `spoke_vpc_self_link`, `spoke_subnet_id`, `spoke_subnet_self_link`
- `hub_vpc_self_link`
- `nat_id`
- `frontend_psc_ip_spoke`, `backend_psc_ip_spoke`, `frontend_psc_ip_hub`
- `google_region` (echo, useful for downstream wiring)

### Restructured (explicit ternaries instead of `try()`)

Old:
```hcl
output "spoke_vpc_id" { value = try(module.network[0].spoke_vpc_id, null) }
```

New:
```hcl
output "spoke_vpc_id" {
  value       = local.databricks_managed ? null : module.network[0].spoke_vpc_id
  description = "Spoke VPC ID (null when vpc_source=databricks_managed)"
}
```

Same behavior; intent is now visible.

## Validation rules added

Two new rules, one in `private-connectivity` (variable-level) and one in the composer (cross-variable, via `preconditions.tf`):

1. **`private-connectivity/variables.tf`**:
```hcl
variable "google_region" {
  type        = string
  description = "GCP region for PSC and firewall resources"
  validation {
    condition = contains([
      "asia-northeast1", "asia-south1", "asia-southeast1", "australia-southeast1",
      "europe-west1", "europe-west2", "europe-west3", "northamerica-northeast1",
      "southamerica-east1", "us-central1", "us-east1", "us-east4", "us-west1", "us-west4"
    ], var.google_region)
    error_message = "google_region must be one of the regions in the regional PSC service-attachment maps. See locals.tf."
  }
}
```

2. **`databricks-workspace/preconditions.tf`** (new rule alongside the 6 existing):
```hcl
precondition {
  condition = (
    !local.any_private_link && !var.restricted_egress
  ) || contains([<same 14-region list>], var.google_region)
  error_message = "google_region must be a region supported by Databricks PSC when any private_link_* flag or restricted_egress is true."
}
```

The 14-region list is duplicated in two places. That's acceptable: they validate different layers (one always, one only when PSC is requested), and the list changes only when Databricks adds a new PSC region (rare).

## README usage examples

Each module README receives a `## Usage` block before the `<!-- BEGIN_TF_DOCS -->` marker. Template:

```markdown
# modules/gcp/<name>

<one-line description>

## Usage

```hcl
module "<short_name>" {
  source = "github.com/databricks/terraform-databricks-examples//modules/gcp/<name>"

  # minimal required inputs
}
```

<scenario-specific notes>

<!-- BEGIN_TF_DOCS -->
... (auto-generated by terraform-docs)
<!-- END_TF_DOCS -->
```

For submodules (`network`, `private-connectivity`, `account`, `dns`), the prose explicitly notes "Typically called by `modules/gcp/databricks-workspace`; consume directly only if you have a reason to."

For the composer (`databricks-workspace`), the prose lists the four supported scenarios and points to the four examples.

For top-level modules (`service-account`, `unity-catalog`), the prose stands alone.

## Migration impact

This refactor is **not** a state-breaking change for the examples in this repo — none of the resource addresses change. The risks are:

| Risk | Mitigation |
|------|-----------|
| `vpc_id` output removed (breaking) | Audit consumers: only the migrated examples consume `module.workspace.vpc_id`. Update them to use `spoke_vpc_id` in the same PR. |
| Submodule output renames break the composer's wiring | Update the composer's `account` module call in the same task that renames the `private-connectivity` outputs. |
| `account` input renames (`*_psc_fr_id` → `*_forwarding_rule_name`) break the composer | Same task. |
| `service-account` module previously self-configured `provider "google"`; consumers that didn't explicitly configure it would break | Only `examples/gcp-sa-provisioning` consumes it, and it already configures `provider "google"`. README is updated to make the requirement explicit. |
| `terraform-docs` regeneration may touch unrelated module READMEs if run from the repo root | All `make docs` invocations during implementation run from the specific module dir (`make -C modules/gcp/<x> docs`), never from `modules/`. |

State migration is not in scope — examples are reference material and customers re-apply on clean state per PR 1's migration documentation.

## Implementation phasing

The work groups into logical commits matching the prior PR-1 squash style:

1. `refactor(gcp): split module files by concern` — file-splitting only, no behavioral changes
2. `refactor(gcp): rename forwarding-rule outputs and account inputs` — coordinated rename across `private-connectivity` and `account`
3. `feat(gcp/databricks-workspace): expand and rename composer outputs` — drop `vpc_id`, add 14 outputs, switch `try()` to explicit ternaries
4. `docs(gcp): add descriptions to all module variables` — ~70 variable descriptions across 5 modules
5. `feat(gcp): add region validations on private-connectivity and composer` — the two new validation rules
6. `refactor(gcp): standardize provider/versions placement` — `versions.tf` everywhere, remove `provider {}` from service-account module, split examples' `init.tf` into `versions.tf` + `providers.tf`
7. `docs(gcp): add `## Usage` sections to module READMEs` — 7 module READMEs updated
8. `docs(gcp): regenerate terraform-docs READMEs` — final regen sweep

Implementation plan will sequence these so each commit leaves the tree validating.

## Open questions

None at this time.
