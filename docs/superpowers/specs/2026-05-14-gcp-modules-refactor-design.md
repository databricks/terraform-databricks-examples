# GCP Modules Refactor — Design Spec

**Date:** 2026-05-14
**Author:** Michele Daddetta
**Status:** Approved (pending implementation plan)

## Problem

Today the repo ships six GCP modules and six GCP example directories. Each example wraps its own dedicated module:

- `examples/gcp-basic` → `modules/gcp-workspace-basic`
- `examples/gcp-byovpc` → `modules/gcp-workspace-byovpc`
- `examples/gcp-with-psc-exfiltration-protection` → `modules/gcp-with-psc-exfiltration-protection`
- `examples/gcp-sa-provisioning` → `modules/gcp-sa-provisioning`
- `examples/gcp-test-modules` (orphan, contains only state files)
- `examples/gcp-sa-provisionning` (typo dir, contains only a Makefile)

The three workspace modules duplicate `databricks_mws_workspaces`, `databricks_mws_networks`, `google_compute_network` + subnet + router + NAT, and `random_string.suffix`. A change to any shared piece (e.g. a new GCP region added to the regional PSC service-attachment map, a workspace argument added by the Databricks provider) needs to land in 2–3 places.

The user's northstar: an example provides only the **basic information about the desired scenario** — does a VPC already exist, what's its name, is the workspace using frontend PrivateLink, is private access enforced — and the module figures out the rest.

There is no "existing VPC" example today; we add one as part of this refactor.

## Goals

1. Eliminate cross-module duplication for GCP workspace deployment.
2. Single top-level composer that takes scenario inputs and conditionally instantiates submodules.
3. Submodules are organized by concern (network, private connectivity, Databricks account resources) and consumed only by the composer.
4. Each example becomes a thin caller — main.tf is ~20 lines and varies only the inputs that matter for that scenario.
5. Variable names describe what they do, not what they protect against. No marketing language.
6. New scenario "existing VPC" is supported on day one.
7. Old modules and examples remain functional during migration; we ship the new modules alongside and migrate one example per PR.

## Non-Goals

- No Unity Catalog redesign. UC remains a separate module that the example wires up directly. The user has separate work in flight for this area.
- No service-account-provisioning redesign. SA-provisioning is a one-time bootstrap with a different lifecycle than the workspace; it remains a separate module called by its own example.
- No state migration tooling for existing applies of old examples. Users re-apply on clean state.
- No new CI test harness (terratest, GitHub Actions matrix). We rely on the existing `pre-commit` config plus per-PR manual sandbox apply.
- No changes to AWS or Azure modules.

## Architecture

### Module layout

```
modules/gcp/
├── databricks-workspace/      # top-level composer; the one examples call
├── network/                   # all google_compute_network/subnet/router/nat/peering
│                              # for both hub & spoke; shared-VPC host/service binding
├── private-connectivity/      # GCP-side: PSC subnet + addresses + forwarding rules
│                              # + egress firewall rules (deny-egress, google-apis, ctl-plane, hive)
├── account/                   # ALL databricks_mws_* resources:
│                              # mws_networks + mws_workspaces + mws_vpc_endpoint
│                              # + mws_private_access_settings
├── dns/                       # private DNS zones + records (hub + spoke)
│                              # split from private-connectivity because DNS needs workspace_url
│                              # which is only available after account creates the workspace
├── service-account/           # relocated from modules/gcp-sa-provisioning (git mv)
└── unity-catalog/             # relocated from modules/gcp-unity-catalog (git mv)
```

The five-submodule split (rather than the three-submodule grouping originally discussed) is required to keep the dependency graph acyclic. `account` cannot live before `private-connectivity` because `databricks_mws_vpc_endpoint` references the PSC forwarding rules created in GCP. `dns` cannot live before `account` because DNS records embed the `workspace_dns_id` regex-extracted from `databricks_mws_workspaces.workspace_url`. Keeping all `databricks_mws_*` resources together in `account` (the user's chosen concern-based grouping) requires DNS to be its own submodule.

### Data flow

```
example
  └── modules/gcp/databricks-workspace (composer)
        ├── modules/gcp/network                 (count = vpc_source != "databricks_managed" ? 1 : 0)
        │     outputs: spoke_vpc_*, spoke_subnet_*, hub_vpc_* (nullable), nat_id (nullable)
        │
        ├── modules/gcp/private-connectivity    (count = any private_link_* flag is true ? 1 : 0)
        │     consumes: network outputs
        │     outputs: frontend_psc_fr_id, backend_psc_fr_id, hub_frontend_psc_fr_id (nullable),
        │              frontend_psc_ip_spoke, backend_psc_ip_spoke, frontend_psc_ip_hub (nullable),
        │              psc_subnet_self_link
        │
        ├── modules/gcp/account                 (always)
        │     consumes: network outputs + private-connectivity outputs
        │     outputs: workspace_id, workspace_url, network_id (nullable),
        │              frontend_endpoint_id, backend_endpoint_id, transit_endpoint_id (nullable)
        │
        └── modules/gcp/dns                     (count = restricted_egress ? 1 : 0)
              consumes: network outputs + private-connectivity PSC IPs + account.workspace_url
              outputs: none

example optionally also calls:
  └── modules/gcp/unity-catalog                 (wired with workspace_id + workspace_url)
```

The composer declares `random_string.suffix` once and passes it to each submodule, eliminating the per-module duplication that exists today.

The dependency graph is linear: `network → private-connectivity → account → dns`. No back-references between modules. `databricks_mws_vpc_endpoint` is created inside `account` (rather than `private-connectivity`) so that `account` owns every `databricks_mws_*` resource and so that the cycle "`account` needs endpoint IDs / DNS needs workspace_url" is decomposed into a linear chain.

## Composer API

```hcl
# === Identity =============================================================
prefix                : string  required
databricks_account_id : string  required
google_project        : string  required   # workspace google project
google_region         : string  required
workspace_name        : string  default = null   # default "${prefix}-ws-${suffix}"
tags                  : map     default = {}

# === Where does the VPC come from? =======================================
vpc_source            : string  default = "databricks_managed"
                         # one of: "databricks_managed", "create", "existing"

# Used when vpc_source = "create"
spoke_vpc_cidr        : string  default = null
subnet_cidr           : string  default = null
pod_cidr              : string  default = null   # GKE secondary range
svc_cidr              : string  default = null   # GKE secondary range

# Used when vpc_source = "existing"
existing_vpc_name     : string  default = null
existing_subnet_name  : string  default = null

# === Connectivity (orthogonal flags, each defaults false) ================
private_link_frontend : bool    default = false   # frontend PSC endpoint + frontend mws_vpc_endpoint
private_link_backend  : bool    default = false   # SCC PSC endpoint + backend mws_vpc_endpoint
private_access_only   : bool    default = false   # mws_private_access_settings; public_access_enabled = false
restricted_egress     : bool    default = false   # hub VPC + deny-egress firewall + private DNS

# === Required when restricted_egress = true ==============================
hub_vpc_google_project   : string  default = null
spoke_vpc_google_project : string  default = null   # falls back to google_project
is_spoke_vpc_shared      : bool    default = false
hub_vpc_cidr             : string  default = null
psc_subnet_cidr          : string  default = null
hive_metastore_ip        : string  default = null   # else looked up via internal regional map
```

### Composer outputs

```hcl
workspace_id   = module.account.workspace_id
workspace_url  = module.account.workspace_url
network_id     = module.account.network_id            # null when vpc_source = "databricks_managed"
vpc_id         = try(module.network[0].spoke_vpc_id, null)
spoke_vpc_id   = try(module.network[0].spoke_vpc_id, null)
hub_vpc_id     = try(module.network[0].hub_vpc_id, null)
suffix         = random_string.suffix.result          # useful for downstream modules (UC, etc.)
```

### Cross-variable validation (preconditions in composer's `main.tf`)

| Rule | Reason |
|------|--------|
| `restricted_egress = true` ⇒ `vpc_source = "create"` | Hub-spoke + egress firewall + private DNS require the module to own both VPCs |
| `restricted_egress = true` ⇒ `private_link_frontend OR private_link_backend = true` | Egress-restricted workspace without PSC is unreachable |
| `restricted_egress = true` ⇒ `hub_vpc_google_project`, `hub_vpc_cidr`, `psc_subnet_cidr` set | Hub topology needs these |
| `vpc_source = "create"` ⇒ `spoke_vpc_cidr`, `subnet_cidr` set | Need CIDRs |
| `vpc_source = "existing"` ⇒ `existing_vpc_name`, `existing_subnet_name` set | Need names to look up |
| `vpc_source = "databricks_managed"` ⇒ `private_link_frontend`, `private_link_backend`, `restricted_egress` all false | Cannot attach PSC or firewalls to a VPC we don't own |

## Submodule contracts

### `modules/gcp/network`

**Inputs:** `prefix`, `suffix`, `google_region`, `vpc_source`, `spoke_vpc_google_project`, `spoke_vpc_cidr`, `subnet_cidr`, `subnet_name`, `pod_cidr`, `svc_cidr`, `existing_vpc_name`, `existing_subnet_name`, `create_hub` (bool — composer passes `restricted_egress`), `hub_vpc_google_project`, `hub_vpc_cidr`, `is_spoke_vpc_shared`, workspace project.

**Behavior:** Spoke VPC + subnet + router + NAT (when `vpc_source = "create"`) or `data` lookups (when `"existing"`). Optional hub VPC + subnet + bidirectional peering + optional shared-VPC host/service binding (when `create_hub`).

**Outputs:** `spoke_vpc_id`, `spoke_vpc_name`, `spoke_vpc_self_link`, `spoke_subnet_id`, `spoke_subnet_name`, `spoke_subnet_self_link`, `hub_vpc_id` (nullable), `hub_vpc_name` (nullable), `hub_vpc_self_link` (nullable), `hub_subnet_name` (nullable), `nat_id` (nullable).

### `modules/gcp/private-connectivity`

**Inputs:** `prefix`, `suffix`, `google_region`, spoke VPC refs + project, hub VPC refs + project (nullable), `enable_frontend`, `enable_backend`, `restrict_egress`, `psc_subnet_cidr`, spoke CIDR (for firewall source ranges), hub CIDR (for hub ingress firewall), `hive_metastore_ip` (nullable; falls back to regional map keyed by `google_region`).

**Behavior, file-organized:**
- `psc.tf`: PSC subnet (in spoke); frontend address + forwarding rule when `enable_frontend`; backend address + forwarding rule when `enable_backend`; hub-side frontend address + forwarding rule when hub exists AND `enable_frontend`. Owns the regional PSC service-attachment maps (`google_frontend_psc_targets` and `google_backend_psc_targets`).
- `firewall.tf`: when `restrict_egress`, creates spoke deny-egress (priority 1100) + allow-google-apis + allow-databricks-control-plane (targeting PSC IPs) + allow-managed-hive (using regional `hive_metastore_ip`); hub ingress from spoke CIDR.

`databricks_mws_vpc_endpoint` resources are NOT created here — they live in `account` so that all `databricks_mws_*` resources are colocated and so the dependency graph stays linear.

**Outputs:** `psc_subnet_self_link`, `frontend_psc_fr_id` (forwarding-rule name; nullable), `backend_psc_fr_id` (nullable), `hub_frontend_psc_fr_id` (nullable), `frontend_psc_ip_spoke`, `backend_psc_ip_spoke`, `frontend_psc_ip_hub` (nullable).

### `modules/gcp/account`

**Inputs:** `prefix`, `suffix`, `workspace_name`, `databricks_account_id`, `google_project`, `google_region`, `vpc_source`, spoke VPC name, spoke subnet name, spoke project, hub project (nullable), `frontend_psc_fr_id` (nullable), `backend_psc_fr_id` (nullable), `hub_frontend_psc_fr_id` (nullable), `enable_frontend`, `enable_backend`, `private_access_only`, `nat_dependency` (passes through `module.network[0].nat_id`).

**Behavior:**
- `databricks_mws_vpc_endpoint` resources (frontend, backend, hub-transit) emitted with `count = 1` gated by the corresponding `enable_*` and forwarding-rule-id inputs. Each references the GCP forwarding rule by name and project.
- `databricks_mws_networks` emitted when `vpc_source != "databricks_managed"`. The `vpc_endpoints` block is populated only when both frontend and backend endpoints exist.
- `databricks_mws_workspaces` always emitted. Single resource with conditional attributes:
  - `network_id` = `databricks_mws_networks.this.network_id` when `vpc_source != "databricks_managed"`, else null
  - `private_access_settings_id` = `databricks_mws_private_access_settings.this.id` when `private_access_only`, else null
  - `depends_on = [nat_dependency]` to make sure NAT is ready before workspace creation
- `databricks_mws_private_access_settings` emitted with `count = 1` when `private_access_only`; sets `public_access_enabled = false` and `private_access_level = "ACCOUNT"`.

**Outputs:** `workspace_id`, `workspace_url`, `network_id` (nullable), `frontend_endpoint_id` (nullable), `backend_endpoint_id` (nullable), `transit_endpoint_id` (nullable).

### `modules/gcp/dns`

**Inputs:** `prefix`, `google_region`, hub VPC refs + project, spoke VPC refs + project, `workspace_url` (from `module.account`), `frontend_psc_ip_spoke`, `frontend_psc_ip_hub` (nullable), `backend_psc_ip_spoke`.

**Behavior:**
- Hub-side: `gcp.databricks.com` zone with `workspace`, `psc-auth`, `dp` records; `gcr.io` zone (wildcard CNAME + A); `googleapis.com` zone (wildcard CNAME to `restricted.googleapis.com` + A); `pkg.dev` zone (wildcard CNAME + A).
- Spoke-side: `gcp.databricks.com` zone with `workspace`, `dp`, `tunnel` records.
- `workspace_dns_id` is the regex-extracted ID from `workspace_url` (matches today's behavior in `gcp-with-psc-exfiltration-protection`).

**Outputs:** none.

### `modules/gcp/service-account` and `modules/gcp/unity-catalog`

Relocated from `modules/gcp-sa-provisioning` and `modules/gcp-unity-catalog` via `git mv`. Variables, outputs, and resource addresses unchanged. Old paths get a deprecation README pointing to the new location.

## Example shapes

Each example dir contains: `init.tf` (providers), `main.tf` (single `module "workspace"` call, optionally plus `module "unity_catalog"`), `variables.tf` (only the variables relevant to that scenario), `terraform.tfvars` (skeleton with empty values + comments), `outputs.tf` (re-exports `workspace_id`/`workspace_url`), `README.md`, `Makefile`.

### `examples/gcp-basic` — Databricks-managed VPC

```hcl
module "workspace" {
  source = "../../modules/gcp/databricks-workspace"

  prefix                = var.prefix
  databricks_account_id = var.databricks_account_id
  google_project        = var.google_project
  google_region         = var.google_region

  vpc_source = "databricks_managed"
}
```

### `examples/gcp-byovpc` — Terraform creates the VPC

```hcl
module "workspace" {
  source = "../../modules/gcp/databricks-workspace"

  prefix                = var.prefix
  databricks_account_id = var.databricks_account_id
  google_project        = var.google_project
  google_region         = var.google_region

  vpc_source     = "create"
  spoke_vpc_cidr = var.spoke_vpc_cidr
  subnet_cidr    = var.subnet_cidr
}
```

### `examples/gcp-existing-vpc` — NEW, fulfills the northstar

```hcl
module "workspace" {
  source = "../../modules/gcp/databricks-workspace"

  prefix                = var.prefix
  databricks_account_id = var.databricks_account_id
  google_project        = var.google_project
  google_region         = var.google_region

  vpc_source           = "existing"
  existing_vpc_name    = var.existing_vpc_name
  existing_subnet_name = var.existing_subnet_name
}
```

### `examples/gcp-with-psc-exfiltration-protection` — PSC + restricted egress

Name kept for backward-compatibility with external links.

```hcl
module "workspace" {
  source = "../../modules/gcp/databricks-workspace"

  prefix                = var.prefix
  databricks_account_id = var.databricks_account_id
  google_project        = var.google_project
  google_region         = var.google_region

  vpc_source     = "create"
  spoke_vpc_cidr = var.spoke_vpc_cidr
  subnet_cidr    = var.subnet_cidr

  private_link_frontend = true
  private_link_backend  = true
  private_access_only   = true
  restricted_egress     = true

  spoke_vpc_google_project = var.spoke_vpc_google_project
  hub_vpc_google_project   = var.hub_vpc_google_project
  is_spoke_vpc_shared      = var.is_spoke_vpc_shared
  hub_vpc_cidr             = var.hub_vpc_cidr
  psc_subnet_cidr          = var.psc_subnet_cidr
}
```

Plus an optional `module "unity_catalog"` block using `module.workspace.workspace_id` and `module.workspace.workspace_url`.

### `examples/gcp-sa-provisioning`

Points at the relocated `modules/gcp/service-account`. Variables and outputs identical to today.

## Migration plan

Build the new modules alongside the old ones; migrate examples one PR at a time.

| PR | Scope | Risk |
|----|-------|------|
| 1 | Add all new modules under `modules/gcp/`. Relocate `service-account` and `unity-catalog` via `git mv` with deprecation stubs at old paths. No example touched. | Low — no example references new code yet |
| 2 | Migrate `examples/gcp-basic` to the new composer. Old `modules/gcp-workspace-basic` stays. | Low — basic case, no PSC/DNS to coordinate |
| 3 | Migrate `examples/gcp-byovpc`. | Low |
| 4 | Migrate `examples/gcp-with-psc-exfiltration-protection`. Sandbox apply + reachability check required. | Medium — PSC + DNS + firewall coordination |
| 5 | Add new `examples/gcp-existing-vpc`. | Low — net-new |
| 6 | Delete `modules/gcp-workspace-basic`, `modules/gcp-workspace-byovpc`, `modules/gcp-with-psc-exfiltration-protection`. Delete deprecation stubs. Delete `examples/gcp-sa-provisionning` (typo dir) and `examples/gcp-test-modules` (state-only). Clean stray `terraform.tfstate*` files from `examples/gcp-*` (verify `.gitignore` first). Update top-level README. | Low |

Each PR is drafted, sandbox-applied by the author, then sent for review. No state migration support — applies of old examples don't transition to the new examples; users re-apply on clean state. Example READMEs document this in PRs 2–4.

## Testing approach

Scoped to what the repo already supports.

**Static (pre-commit, every PR):**
- `terraform fmt -recursive`
- `terraform validate` per module and per example
- `terraform-docs` regeneration check

**Module-level plan smoke (PR 1):**
For each new submodule, a `tests/` subdir with minimal-fixture `terraform plan` invocations using mock vars (e.g. `databricks_account_id = "00000000-0000-0000-0000-000000000000"`). Run with `terraform init -backend=false && terraform validate && terraform plan -refresh=false`. Wrapped in a Makefile target. Catches missing required inputs and broken preconditions before any sandbox apply.

Negative cases that must fail at plan time (one fixture each):
- `restricted_egress = true` + `vpc_source = "databricks_managed"`
- `restricted_egress = true` + `hub_vpc_cidr = null`
- `vpc_source = "existing"` + `existing_vpc_name = null`
- `private_link_frontend = true` + `vpc_source = "databricks_managed"`

**Example-level apply (manual, before each migration PR merges):**
- Apply against sandbox GCP project + Databricks account
- Verify workspace reachable; UC accessible where applicable
- Fresh `terraform plan` against applied state — expect zero drift
- `terraform destroy` and confirm clean teardown (PSC + DNS ordering)
- Capture plan/apply output in the PR description

**What we don't test:** terratest, GitHub Actions matrix, automated cost guards, upgrade-from-old-state. Out of scope.

## Risks & mitigations

| Risk | Mitigation |
|------|-----------|
| Regional PSC service-attachment map drift between old and new modules during transition | Both reference the same Databricks-published list; copy verbatim to new module, delete old in PR 6 |
| Cross-variable `precondition` failures only surface at plan time, not at `validate` | Module-level plan-smoke fixtures in `tests/` exercise every precondition |
| `databricks_mws_workspaces` resource address changes (module path differs) | Acknowledged: examples are throwaway, customer state is unaffected. Documented in migration PRs |
| Empty `modules/gcp/network/` dir already exists | Becomes the home for the new `network` submodule — no conflict |
| User's separate UC work conflicts with the relocation `git mv` | Relocate but do not modify UC contents in PR 1; user's UC work can land before or after relocation as desired |
| PSC + DNS teardown ordering issues during `terraform destroy` | Add explicit `depends_on` between DNS records and the PSC forwarding rules they reference; verify during PR 4 sandbox test |

## Open questions

None at this time. All design choices ratified during the brainstorming session on 2026-05-14.
