# GCP Hardening Fixes, Cross-Cloud Contract & Compute Features — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix the 13 review findings on PR #233, ship the cross-cloud module contract with the `account`→`workspace` rename, and add serverless egress control, CMEK, GKE-CIDR removal, and a shared security-settings module.

**Architecture:** The GCP composer (`modules/gcp/databricks-workspace`) conditionally wires four submodules (`network → private-connectivity → workspace → dns`). Fixes make all conditional logic plan-time static and restore restricted-egress parity with the deleted legacy module. Features land in the `workspace` submodule (account-level resources) and a new cloud-neutral `modules/databricks/security-settings` (workspace-level provider).

**Tech Stack:** Terraform ≥ 1.5 (dev machine has 1.14), `hashicorp/google` provider, `databricks/databricks` provider, terraform-docs via per-module Makefiles.

**Spec:** `docs/superpowers/specs/2026-07-08-gcp-hardening-features-design.md`

## Global Constraints

- Repo: `/Users/michele.daddetta/Documents/Databricks/terraform-databricks-examples`, branch `feature/gcp-modules-refactor` (head branch of draft PR #233). Work directly on this branch.
- Module version floors: `google >= 6.0`, `databricks >= 1.81.1`, `random >= 3.0`. Examples pin `~> 6.17` (google) and `~> 1.81` (databricks). No `null` provider anywhere after Task 9. No `provider {}` blocks inside modules.
- "Validate" for a module means: `terraform init -backend=false -upgrade >/dev/null && terraform validate` run in the module directory. "Fixture plan" means the same init then `terraform plan` in `tests/<scenario>/`. Fixture plans run offline — no GCP/Databricks credentials needed (the `tests/existing-vpc` and `modules/gcp/network/tests/existing` fixtures are the exception: they hit real data sources and are excluded from checks).
- Negative fixtures must FAIL `terraform plan` with the exact error message asserted in the task.
- Run `terraform fmt -recursive modules/gcp modules/databricks examples` before every commit.
- Every commit message ends with `Co-authored-by: Isaac` on its own line.
- Tasks 1–9 use `modules/gcp/account/...` paths; Task 10 renames the directory to `modules/gcp/workspace/`; Tasks 11+ use the new path. Do not reorder across that boundary.
- **Do NOT push or edit the GitHub PR until the explicit CHECKPOINT in Task 16 — Michele approves pushes.**

---

### Task 1: Static count gating (fix F1 — blocker)

`count` expressions currently depend on apply-time values (forwarding-rule names embedding `random_string.suffix`, `hub_vpc_id` resource attribute). Gate everything on static booleans.

**Files:**
- Modify: `modules/gcp/private-connectivity/variables.tf`, `locals.tf`, `psc.tf`, `firewall.tf`, `outputs.tf`
- Modify: `modules/gcp/account/variables.tf`, `locals.tf`, `vpc-endpoints.tf`, `outputs.tf`
- Modify: `modules/gcp/databricks-workspace/main.tf`
- Modify: `modules/gcp/private-connectivity/tests/full-isolated/main.tf`, `modules/gcp/account/tests/psc-with-pas/main.tf`

**Interfaces:**
- Produces: `private-connectivity` and `account` both gain `variable "create_hub"` (bool, default `false`). The composer passes `create_hub = var.restricted_egress` to both. Later tasks rely on `var.create_hub` existing in both submodules.

- [ ] **Step 1: Reproduce the failure**

Run: `cd modules/gcp/databricks-workspace/tests/psc-isolated && terraform init -backend=false -upgrade >/dev/null && terraform plan`
Expected: FAIL with 4 × `Invalid count argument` (account frontend/backend endpoints, private-connectivity hub address/forwarding rule).

- [ ] **Step 2: Add `create_hub` to private-connectivity and remove `hub_present`**

Append to `modules/gcp/private-connectivity/variables.tf`:

```hcl
variable "create_hub" {
  type        = bool
  default     = false
  description = "Whether the hub VPC exists (composer passes restricted_egress). Gates hub-side PSC and firewall resources; must be plan-time static"
}
```

In `modules/gcp/private-connectivity/locals.tf` delete the line:

```hcl
  hub_present = var.hub_vpc_id != null
```

Replace every `local.hub_present` with `var.create_hub`:
- `psc.tf:59` and `psc.tf:69` → `count = var.create_hub && var.enable_frontend ? 1 : 0`
- `firewall.tf:83` (`hub_ingress`) → `count = var.restrict_egress && var.create_hub ? 1 : 0`
- `outputs.tf` (`hub_frontend_forwarding_rule_name`, `frontend_psc_ip_hub`) → condition `var.create_hub && var.enable_frontend`

- [ ] **Step 3: Gate account endpoint counts on flags**

Append to `modules/gcp/account/variables.tf`:

```hcl
variable "create_hub" {
  type        = bool
  default     = false
  description = "Whether a hub VPC exists (composer passes restricted_egress). Gates the transit mws_vpc_endpoint; must be plan-time static"
}
```

In `modules/gcp/account/vpc-endpoints.tf` change the three counts:

```hcl
resource "databricks_mws_vpc_endpoint" "frontend" {
  count = var.enable_frontend ? 1 : 0
```

```hcl
resource "databricks_mws_vpc_endpoint" "backend" {
  count = var.enable_backend ? 1 : 0
```

```hcl
resource "databricks_mws_vpc_endpoint" "transit" {
  count = var.enable_frontend && var.create_hub ? 1 : 0
```

In `modules/gcp/account/locals.tf`:

```hcl
  emit_vpc_endpoints = var.enable_frontend && var.enable_backend
```

In `modules/gcp/account/outputs.tf` simplify the three endpoint output conditions:

```hcl
output "frontend_endpoint_id" {
  value       = var.enable_frontend ? databricks_mws_vpc_endpoint.frontend[0].vpc_endpoint_id : null
  description = "Frontend mws_vpc_endpoint ID (null when no PSC)"
}

output "backend_endpoint_id" {
  value       = var.enable_backend ? databricks_mws_vpc_endpoint.backend[0].vpc_endpoint_id : null
  description = "Backend mws_vpc_endpoint ID (null when no PSC)"
}

output "transit_endpoint_id" {
  value       = var.enable_frontend && var.create_hub ? databricks_mws_vpc_endpoint.transit[0].vpc_endpoint_id : null
  description = "Hub-side mws_vpc_endpoint ID (null when no hub)"
}
```

In `modules/gcp/account/variables.tf`, fix the three forwarding-rule variable descriptions (they no longer gate anything): change each `; gates ... creation` suffix to `; used as gcp_vpc_endpoint_info.psc_endpoint_name`.

- [ ] **Step 4: Wire `create_hub` through the composer**

In `modules/gcp/databricks-workspace/main.tf` add to the `module "private_connectivity"` block (after `restrict_egress = var.restricted_egress`):

```hcl
  create_hub      = var.restricted_egress
```

and to the `module "account"` block (after `private_access_only = var.private_access_only`):

```hcl
  create_hub          = var.restricted_egress
```

- [ ] **Step 5: Update submodule fixtures**

Add `create_hub = true` to the module block in `modules/gcp/private-connectivity/tests/full-isolated/main.tf` (after `restrict_egress = true`) and in `modules/gcp/account/tests/psc-with-pas/main.tf` (after `private_access_only = true`).

- [ ] **Step 6: Verify**

Run fixture plans; all must complete without `Invalid count argument`:
- `modules/gcp/databricks-workspace/tests/psc-isolated` → plan succeeds (this is the blocker acceptance)
- `modules/gcp/databricks-workspace/tests/basic`, `tests/byovpc` → still succeed
- `modules/gcp/private-connectivity/tests/full-isolated`, `tests/no-egress` → succeed
- `modules/gcp/account/tests/psc-with-pas`, `tests/byovpc`, `tests/databricks-managed` → succeed

- [ ] **Step 7: Commit**

```bash
git add modules/gcp/private-connectivity modules/gcp/account modules/gcp/databricks-workspace
git commit -m "fix(gcp): gate PSC resource counts on plan-time-static flags

The psc-isolated composer fixture failed 'terraform plan' with 4x Invalid
count argument: counts depended on forwarding-rule names (which embed the
random suffix) and on hub_vpc_id (a resource attribute). Counts now gate on
enable_frontend/enable_backend/create_hub booleans.

Co-authored-by: Isaac"
```

---

### Task 2: Restore spoke peering DNS zones (fix F2 — blocker)

Under restricted egress the spoke VPC must resolve `googleapis.com`/`gcr.io`/`pkg.dev` privately. Private zones don't propagate over VPC peering; the old module gave the spoke *peering zones* delegating to the hub's record-bearing zones.

**Files:**
- Modify: `modules/gcp/dns/spoke.tf`
- Test: `modules/gcp/dns/tests/hub-and-spoke/main.tf` (no changes needed — verify count)

**Interfaces:**
- Consumes: `var.hub_vpc_id`, `var.spoke_vpc_id`, `var.spoke_vpc_google_project` (already declared in `modules/gcp/dns/variables.tf`).

- [ ] **Step 1: Baseline fixture count**

Run: `cd modules/gcp/dns/tests/hub-and-spoke && terraform init -backend=false -upgrade >/dev/null && terraform plan`
Expected: `Plan: 16 to add` (4 zones + 12 record sets).

- [ ] **Step 2: Append peering zones to `modules/gcp/dns/spoke.tf`**

```hcl
# === Peering zones (spoke → hub) =========================================
# Private zones do not propagate over VPC peering. The hub hosts the
# record-bearing zones for googleapis.com / gcr.io / pkg.dev; these peering
# zones make them resolvable from the spoke.
resource "google_dns_managed_zone" "spoke_peering_google_apis" {
  name        = "${var.prefix}-peering-google-apis"
  project     = var.spoke_vpc_google_project
  dns_name    = "googleapis.com."
  description = "Peering DNS zone delegating googleapis.com resolution to the hub VPC"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = var.spoke_vpc_id
    }
  }

  peering_config {
    target_network {
      network_url = var.hub_vpc_id
    }
  }
}

resource "google_dns_managed_zone" "spoke_peering_gcr" {
  name        = "${var.prefix}-peering-gcr"
  project     = var.spoke_vpc_google_project
  dns_name    = "gcr.io."
  description = "Peering DNS zone delegating gcr.io resolution to the hub VPC"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = var.spoke_vpc_id
    }
  }

  peering_config {
    target_network {
      network_url = var.hub_vpc_id
    }
  }
}

resource "google_dns_managed_zone" "spoke_peering_pkg_dev" {
  name        = "${var.prefix}-peering-pkg-dev"
  project     = var.spoke_vpc_google_project
  dns_name    = "pkg.dev."
  description = "Peering DNS zone delegating pkg.dev resolution to the hub VPC"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = var.spoke_vpc_id
    }
  }

  peering_config {
    target_network {
      network_url = var.hub_vpc_id
    }
  }
}
```

- [ ] **Step 3: Verify**

Re-run the fixture plan. Expected: `Plan: 19 to add`, including the three `google_dns_managed_zone.spoke_peering_*` zones. Composer `tests/psc-isolated` plan still succeeds.

- [ ] **Step 4: Commit**

```bash
git add modules/gcp/dns
git commit -m "fix(gcp/dns): restore spoke peering zones for googleapis/gcr/pkg.dev

Private zones attached only to the hub are invisible to the spoke across
VPC peering, so restricted-egress spokes resolved Google APIs to public IPs
that the deny-egress rule blocks - breaking cluster launch, GCS and GCR.
Parity restore from the deleted module's dns-spoke.tf.

Co-authored-by: Isaac"
```

---

### Task 3: Restore intra-VPC firewall rules (fix F3 — blocker)

The deny-egress rule (priority 1100) also blocks node-to-node traffic, and GCP ingress is implied-deny. Restore the legacy module's intra-VPC allows.

**Files:**
- Modify: `modules/gcp/private-connectivity/firewall.tf`

- [ ] **Step 1: Append the two rules to `firewall.tf`**

```hcl
# === Intra-VPC traffic (cluster node-to-node) ===========================
# The deny-egress rule above also covers RFC1918 space, and GCP ingress is
# implied-deny. Without these two allows, Spark clusters cannot form.
# The legacy module scoped ingress with workspace-id target_tags; this
# module runs before the workspace exists, so the rule applies VPC-wide -
# acceptable because the spoke VPC is dedicated to Databricks.
resource "google_compute_firewall" "spoke_intra_egress" {
  count = var.restrict_egress ? 1 : 0

  name    = "${var.prefix}-spoke-${var.suffix}-intra-egress"
  project = var.spoke_vpc_google_project
  network = var.spoke_vpc_self_link

  direction          = "EGRESS"
  priority           = 1000
  destination_ranges = [var.spoke_vpc_cidr]

  allow {
    protocol = "all"
  }
}

resource "google_compute_firewall" "spoke_intra_ingress" {
  count = var.restrict_egress ? 1 : 0

  name    = "${var.prefix}-spoke-${var.suffix}-intra-ingress"
  project = var.spoke_vpc_google_project
  network = var.spoke_vpc_self_link

  direction     = "INGRESS"
  priority      = 1000
  source_ranges = [var.spoke_vpc_cidr]

  allow {
    protocol = "all"
  }
}
```

- [ ] **Step 2: Verify**

`modules/gcp/private-connectivity/tests/full-isolated` plan: previously `Plan: 12 to add`, now `Plan: 14 to add` with both `spoke_intra_*` rules present. `tests/no-egress` plan unchanged (no firewall stack).

- [ ] **Step 3: Commit**

```bash
git add modules/gcp/private-connectivity
git commit -m "fix(gcp/private-connectivity): restore intra-VPC allow rules under restricted egress

Parity restore from the deleted module's firewall-spoke.tf: EGRESS allow to
the spoke CIDR (beats the 1100 deny) and INGRESS allow from the spoke CIDR
(GCP ingress is implied-deny). Without both, node-to-node Spark traffic is
blocked and clusters never form.

Co-authored-by: Isaac"
```

---

### Task 4: PSC flag-equality + psc_subnet_cidr preconditions (fixes F4, F5, F6)

GCP's `databricks_mws_networks.vpc_endpoints` requires both `dataplane_relay` and `rest_api`, so single-sided PSC is not expressible (verified against GCP PSC docs). Enforce flag equality at plan time; extend the `psc_subnet_cidr` rule to all PSC scenarios.

**Files:**
- Modify: `modules/gcp/databricks-workspace/preconditions.tf`, `variables.tf`
- Create: `modules/gcp/databricks-workspace/tests/negative-psc-single-sided/main.tf`
- Create: `modules/gcp/databricks-workspace/tests/negative-psc-missing-subnet-cidr/main.tf`

- [ ] **Step 1: Add/extend preconditions**

In `modules/gcp/databricks-workspace/preconditions.tf`, insert after the second precondition (the `restricted_egress requires at least one` rule):

```hcl
    precondition {
      condition     = var.private_link_frontend == var.private_link_backend
      error_message = "On GCP, private_link_frontend and private_link_backend must be enabled together: databricks_mws_networks.vpc_endpoints requires both dataplane_relay and rest_api endpoint references. (The flags stay independent in the cross-cloud contract for clouds that support single-sided PrivateLink.)"
    }
```

Replace the third precondition (hub requirements) condition to also require `psc_subnet_cidr` under plain PSC — change:

```hcl
    precondition {
      condition     = !local.any_private_link || var.psc_subnet_cidr != null
      error_message = "psc_subnet_cidr is required when any private_link_* flag is true."
    }
    precondition {
      condition     = !var.restricted_egress || (var.hub_vpc_google_project != null && var.hub_vpc_cidr != null)
      error_message = "restricted_egress=true requires hub_vpc_google_project and hub_vpc_cidr."
    }
```

(i.e. `psc_subnet_cidr` moves out of the hub rule into its own rule keyed on `any_private_link`; since `restricted_egress` already requires a `private_link_*` flag, it is covered transitively.)

- [ ] **Step 2: Update the two flag descriptions in composer `variables.tf`**

Append to the `private_link_frontend` and `private_link_backend` descriptions: `. On GCP both flags must be enabled together (see preconditions.tf)`.

- [ ] **Step 3: Write the negative fixtures**

`modules/gcp/databricks-workspace/tests/negative-psc-single-sided/main.tf`:

```hcl
terraform {
  required_version = ">= 1.5"
  required_providers {
    databricks = { source = "databricks/databricks" }
    google     = { source = "hashicorp/google" }
  }
}

provider "google" {
  project = "fixture-workspace"
  region  = "us-central1"
}

provider "databricks" {
  host       = "https://accounts.gcp.databricks.com"
  account_id = "00000000-0000-0000-0000-000000000000"
}

# precondition fail: frontend without backend (GCP requires both)
module "workspace" {
  source = "../.."

  prefix                = "fixture"
  databricks_account_id = "00000000-0000-0000-0000-000000000000"
  google_project        = "fixture-workspace"
  google_region         = "us-central1"

  vpc_source     = "create"
  spoke_vpc_cidr = "10.0.0.0/16"
  subnet_cidr    = "10.0.0.0/22"

  private_link_frontend = true
  private_link_backend  = false
  psc_subnet_cidr       = "10.0.255.0/28"
}
```

`modules/gcp/databricks-workspace/tests/negative-psc-missing-subnet-cidr/main.tf`: same header/providers, module block:

```hcl
# precondition fail: PSC flags without psc_subnet_cidr
module "workspace" {
  source = "../.."

  prefix                = "fixture"
  databricks_account_id = "00000000-0000-0000-0000-000000000000"
  google_project        = "fixture-workspace"
  google_region         = "us-central1"

  vpc_source     = "create"
  spoke_vpc_cidr = "10.0.0.0/16"
  subnet_cidr    = "10.0.0.0/22"

  private_link_frontend = true
  private_link_backend  = true
}
```

- [ ] **Step 4: Verify**

- Both new fixtures FAIL plan with their respective error messages (`must be enabled together`, `psc_subnet_cidr is required`).
- All 4 existing negative fixtures still fail with their original messages.
- `psc-isolated`, `basic`, `byovpc` positive fixtures still plan.

- [ ] **Step 5: Commit**

```bash
git add modules/gcp/databricks-workspace
git commit -m "fix(gcp): enforce PSC flag equality and psc_subnet_cidr at plan time

GCP's mws_networks.vpc_endpoints requires both dataplane_relay and rest_api,
so single-sided PSC configs previously passed preconditions and broke at
apply (null DNS rrdatas, missing control-plane allow rule, silently
unattached endpoints). psc_subnet_cidr is now required for any PSC scenario,
matching its documented contract.

Co-authored-by: Isaac"
```

---

### Task 5: Hive metastore rule honesty (fix F7)

**Files:**
- Modify: `modules/gcp/private-connectivity/locals.tf`, `firewall.tf`, `variables.tf`
- Modify: `modules/gcp/databricks-workspace/variables.tf`

- [ ] **Step 1: Remove the empty-map lookup**

In `modules/gcp/private-connectivity/locals.tf` delete the `default_hive_metastore_ips = { }` map (with its comment block) and the `hive_metastore_ip = ...` local.

In `firewall.tf` (`spoke_allow_hive`):

```hcl
  count = var.restrict_egress && var.hive_metastore_ip != null ? 1 : 0
```

and

```hcl
  destination_ranges = ["${var.hive_metastore_ip}/32"]
```

- [ ] **Step 2: Fix both descriptions**

`modules/gcp/private-connectivity/variables.tf` → `hive_metastore_ip`:

```hcl
  description = "Regional legacy Hive metastore IP. When set, an egress allow rule (tcp/3306) is created under restricted egress; when null, no rule is created. Workspaces using Unity Catalog (the default) do not need this. Regional IPs: https://docs.databricks.com/gcp/en/resources/ip-domain-region"
```

`modules/gcp/databricks-workspace/variables.tf` → `hive_metastore_ip`: same text.

- [ ] **Step 3: Verify & commit**

`full-isolated` fixture plan: no `spoke_allow_hive` rule (fixture doesn't set the IP), total `Plan: 14 to add` unchanged from Task 3. Module validate passes.

```bash
git add modules/gcp/private-connectivity modules/gcp/databricks-workspace
git commit -m "fix(gcp/private-connectivity): drop phantom hive metastore IP lookup

The variable promised an internal regional-default lookup backed by an
empty map, so omitting hive_metastore_ip silently dropped the legacy HMS
allow rule. The rule is now explicitly opt-in and the docs say so; UC
workspaces (the default) do not need it.

Co-authored-by: Isaac"
```

---

### Task 6: No NAT under restricted egress (fix F8)

**Files:**
- Modify: `modules/gcp/network/variables.tf`, `nat.tf`, `outputs.tf`
- Modify: `modules/gcp/databricks-workspace/main.tf`, `outputs.tf`

- [ ] **Step 1: Add `enable_nat` to the network module**

Append to `modules/gcp/network/variables.tf`:

```hcl
variable "enable_nat" {
  type        = bool
  default     = true
  description = "Create Cloud Router + NAT for internet egress. The composer disables this under restricted_egress, where no internet egress path may exist"
}
```

In `nat.tf`, both resources:

```hcl
  count = local.create_vpc && var.enable_nat ? 1 : 0
```

In `outputs.tf`:

```hcl
output "nat_id" {
  value       = local.create_vpc && var.enable_nat ? google_compute_router_nat.nat[0].id : null
  description = "ID of the Cloud NAT (null when vpc_source=existing or enable_nat=false)"
}
```

- [ ] **Step 2: Composer wiring**

In `modules/gcp/databricks-workspace/main.tf` `module "network"` block add:

```hcl
  enable_nat = !var.restricted_egress
```

In `modules/gcp/databricks-workspace/outputs.tf`:

```hcl
output "nat_id" {
  value       = local.create_vpc && !var.restricted_egress ? module.network[0].nat_id : null
  description = "Cloud NAT ID (null when vpc_source != create or when restricted_egress=true)"
}
```

- [ ] **Step 3: Verify & commit**

`tests/psc-isolated` plan no longer contains `google_compute_router` or `google_compute_router_nat`; `tests/byovpc` still contains both.

```bash
git add modules/gcp/network modules/gcp/databricks-workspace
git commit -m "fix(gcp): create no Cloud NAT in the restricted-egress topology

The exfiltration-protection design deliberately has no internet egress
path; the refactor had reintroduced NAT unconditionally for created VPCs.

Co-authored-by: Isaac"
```

---

### Task 7: Widen the Shared-VPC gate (fix F9)

**Files:**
- Modify: `modules/gcp/network/shared-vpc.tf`
- Modify: `modules/gcp/databricks-workspace/variables.tf`
- Create: `modules/gcp/network/tests/create-shared/main.tf`

- [ ] **Step 1: Drop the hub requirement**

`modules/gcp/network/shared-vpc.tf`, both resources:

```hcl
  count = var.is_spoke_vpc_shared && var.workspace_google_project != var.spoke_vpc_google_project ? 1 : 0
```

- [ ] **Step 2: Fix the composer description**

`modules/gcp/databricks-workspace/variables.tf` → `is_spoke_vpc_shared` description becomes:

```hcl
  description = "If true and the spoke VPC project differs from the workspace project, bind the spoke project as a Shared-VPC host and the workspace project as a service project. Works with or without restricted_egress"
```

- [ ] **Step 3: New fixture** `modules/gcp/network/tests/create-shared/main.tf`:

```hcl
terraform {
  required_version = ">= 1.5"
}

provider "google" {
  project = "fixture-project"
  region  = "us-central1"
}

# Shared-VPC binding without a hub (BYOVPC + Shared VPC)
module "network" {
  source = "../.."

  prefix                   = "fixture"
  suffix                   = "abc123"
  google_region            = "us-central1"
  vpc_source               = "create"
  spoke_vpc_google_project = "fixture-host-project"
  spoke_vpc_cidr           = "10.0.0.0/16"
  subnet_cidr              = "10.0.0.0/22"

  is_spoke_vpc_shared      = true
  workspace_google_project = "fixture-workspace-project"
}
```

- [ ] **Step 4: Verify & commit**

New fixture plans with both `google_compute_shared_vpc_host_project.host` and `..._service_project.service`; `create-with-hub` fixture unchanged.

```bash
git add modules/gcp/network modules/gcp/databricks-workspace
git commit -m "fix(gcp/network): allow Shared-VPC binding without a hub

BYOVPC + Shared VPC (no restricted egress) was expressible in the legacy
modules but the refactor gated the binding on create_hub.

Co-authored-by: Isaac"
```

---

### Task 8: Remove dead variables, tags pass-through, PAT token, resource-level account_id (fixes F10, F11-behavior)

**Files:**
- Modify: `modules/gcp/network/variables.tf`; fixtures `tests/create/main.tf`, `tests/create-with-hub/main.tf`
- Modify: `modules/gcp/private-connectivity/variables.tf`; fixture `tests/full-isolated/main.tf`
- Modify: `modules/gcp/dns/variables.tf`; fixture `tests/hub-and-spoke/main.tf`
- Modify: `modules/gcp/databricks-workspace/main.tf`
- Modify: `modules/gcp/account/workspace.tf`, `networks.tf`, `pas.tf`, `vpc-endpoints.tf`
- Modify: `examples/gcp-with-psc-exfiltration-protection/main.tf`, `variables.tf`, `terraform.tfvars`
- Delete: `examples/gcp-byovpc/data.tf`

- [ ] **Step 1: Dead variables**

Delete these variable blocks and every reference to them:
- `modules/gcp/network/variables.tf`: `spoke_vpc_cidr` (unused inside the module). Remove `spoke_vpc_cidr = var.spoke_vpc_cidr` from the composer's `module "network"` block and the `spoke_vpc_cidr` lines from `modules/gcp/network/tests/create/main.tf` and `tests/create-with-hub/main.tf`. (The composer-level `spoke_vpc_cidr` variable stays — private-connectivity consumes it.)
- `modules/gcp/private-connectivity/variables.tf`: `hub_vpc_cidr` ("reserved for future use"). Remove `hub_vpc_cidr = var.hub_vpc_cidr` from the composer's `module "private_connectivity"` block and the `hub_vpc_cidr` line from `tests/full-isolated/main.tf`.
- `modules/gcp/dns/variables.tf`: `hub_vpc_self_link` and `spoke_vpc_self_link` (never referenced). Remove both from the composer's `module "dns"` block and from `modules/gcp/dns/tests/hub-and-spoke/main.tf` (lines `hub_vpc_self_link = ...` and `spoke_vpc_self_link = ...`).

- [ ] **Step 2: Stop passing `tags` in the PSC example**

- `examples/gcp-with-psc-exfiltration-protection/main.tf`: delete `tags = var.tags`.
- `variables.tf`: delete the whole `variable "tags"` block (lines 63–66).
- `terraform.tfvars`: delete the `tags = {}` line.

(The composer's `tags` variable itself stays, documented as reserved — prior decision.)

- [ ] **Step 3: Remove the PAT `token {}` block**

In `modules/gcp/account/workspace.tf` delete:

```hcl
  token {
    comment = "Terraform"
  }
```

- [ ] **Step 4: Remove resource-level `account_id`**

Delete the `account_id = var.databricks_account_id` line from: `workspace.tf`, `networks.tf`, `pas.tf`, and all three resources in `vpc-endpoints.tf`. The account-level provider carries `account_id` (all fixtures and examples already configure it). The `databricks_account_id` module variable stays (Task 12 CMEK does not need it either, but the composer still accepts it for the provider-configuration story documented in examples). If `terraform validate` reports the attribute as required, restore it only where required and note the provider version in the commit body.

- [ ] **Step 5: Delete `examples/gcp-byovpc/data.tf`** (both data sources are unused).

- [ ] **Step 6: Verify & commit**

All module validates pass; `psc-isolated`, `basic`, `byovpc`, dns, network, private-connectivity fixtures plan; PSC example `terraform init -backend=false && terraform validate` passes.

```bash
git add -A modules/gcp examples/gcp-with-psc-exfiltration-protection examples/gcp-byovpc
git commit -m "refactor(gcp): drop dead variables, tags pass-through, module-created PAT, resource-level account_id

- network.spoke_vpc_cidr, private-connectivity.hub_vpc_cidr and the dns
  self-link inputs were wired through but never consumed
- the PSC example passed tags, implying an effect the composer doesn't have
- the workspace module created a PAT the legacy module never did; tokens
  don't belong in module state
- account_id on mws_* resources is deprecated in favor of the provider block

Co-authored-by: Isaac"
```

---

### Task 9: Version-constraint policy + Terraform idioms (fixes F12, F13)

**Files:**
- Modify: all seven `modules/gcp/*/versions.tf`
- Modify: `modules/gcp/databricks-workspace/preconditions.tf`
- Modify: `modules/gcp/private-connectivity/firewall.tf`
- Modify: `modules/gcp/account/workspace.tf`, `variables.tf`
- Modify: `examples/gcp-basic/versions.tf`, `examples/gcp-byovpc/versions.tf`, `examples/gcp-existing-vpc/versions.tf`, `examples/gcp-with-psc-exfiltration-protection/versions.tf`

- [ ] **Step 1: Module floors**

Set every module's `versions.tf` to declare only the providers it uses, with floors `google >= 6.0`, `databricks >= 1.81.1`, `random >= 3.0`:

- `network`, `dns`, `service-account`: google only.
- `private-connectivity`: google only.
- `account`: databricks only (`>= 1.81.1`).
- `unity-catalog`: keep the existing `configuration_aliases` block, add `version = ">= 1.81.1"` (databricks) and `version = ">= 6.0"` (google), `version = ">= 3.0"` (random), and add `required_version = ">= 1.5"`.
- `databricks-workspace` (composer): google `>= 6.0`, databricks `>= 1.81.1`, random `>= 3.0`, and **delete the `null` provider block**.

Template (adjust the provider set per module):

```hcl
terraform {
  required_version = ">= 1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0"
    }
  }
}
```

- [ ] **Step 2: Example pins**

All four example `versions.tf` files get this exact content (PSC example keeps its `random` entry, adding `version = ">= 3.0"`):

```hcl
terraform {
  required_version = ">= 1.5"
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.81"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 6.17"
    }
  }
}
```

- [ ] **Step 3: `null_resource` → `terraform_data`**

In `modules/gcp/databricks-workspace/preconditions.tf` change the wrapper only (all precondition blocks stay):

```hcl
# Cross-variable preconditions.
resource "terraform_data" "preconditions" {
  lifecycle {
```

- [ ] **Step 4: Firewall no-op attribute cleanup**

`modules/gcp/private-connectivity/firewall.tf`: delete `source_ranges      = []` from `spoke_default_deny_egress` and `destination_ranges = []` from `hub_ingress`.

- [ ] **Step 5: `nat_dependency` bridge**

In `modules/gcp/account/workspace.tf`, prepend:

```hcl
# Bridge an opaque upstream dependency (Cloud NAT readiness) into the graph.
resource "terraform_data" "nat_gate" {
  input = var.nat_dependency
}
```

and change the workspace's `depends_on = [var.nat_dependency]` to `depends_on = [terraform_data.nat_gate]`.

- [ ] **Step 6: Verify & commit**

Every module validate passes after `terraform init -backend=false -upgrade`; all positive fixtures plan; negative fixtures still fail with their messages; `.terraform.lock.hcl` in fixtures no longer pins `hashicorp/null` for the composer fixtures.

```bash
git add -A modules/gcp examples
git commit -m "refactor(gcp): standardize provider constraints and adopt terraform_data

Modules declare floors (google >= 6.0, databricks >= 1.81.1); examples pin
pessimistically (~> 6.17, ~> 1.81). Preconditions and the NAT dependency
bridge use the built-in terraform_data instead of null_resource, dropping
the null provider. Removes no-op firewall attributes.

Co-authored-by: Isaac"
```

---

### Task 10: Rename `modules/gcp/account` → `modules/gcp/workspace`

Contract slot name: the module owns everything that registers the workspace with the Databricks control plane. `account` doesn't port to Azure (no account API layer there).

**Files:**
- Rename: `modules/gcp/account/` → `modules/gcp/workspace/` (git mv)
- Modify: `modules/gcp/databricks-workspace/main.tf`, `outputs.tf`, `README.md`
- Modify: the three fixtures inside the renamed module
- Modify: `README.md` (repo root) if it references `modules/gcp/account`

- [ ] **Step 1: Move**

```bash
git mv modules/gcp/account modules/gcp/workspace
```

- [ ] **Step 2: Composer rewiring**

In `modules/gcp/databricks-workspace/main.tf`: rename the block `module "account"` → `module "workspace"` and its `source = "../account"` → `source = "../workspace"`. In the `module "dns"` block change `workspace_url = module.account.workspace_url` → `module.workspace.workspace_url`.

In `modules/gcp/databricks-workspace/outputs.tf`: replace every `module.account.` with `module.workspace.` (7 occurrences: workspace_id, workspace_url, network_id, private_access_settings_id, frontend/backend/transit endpoint IDs).

- [ ] **Step 3: Fixture labels**

In `modules/gcp/workspace/tests/{byovpc,databricks-managed,psc-with-pas}/main.tf` rename the module block label `module "account"` → `module "workspace"` (source stays `../..`).

- [ ] **Step 4: Docs touch-ups**

- `modules/gcp/workspace/README.md`: change the H1 to `# modules/gcp/workspace` and the first prose line to say it owns workspace registration with the Databricks control plane (`databricks_mws_*`). Full regen happens in Task 16.
- `modules/gcp/databricks-workspace/README.md`: add one line under the intro: `Not to be confused with the workspace submodule (../workspace), which this composer calls to register the workspace with the Databricks control plane.`
- Repo root `README.md`: `grep -n "modules/gcp/account" README.md` — update any hit to `modules/gcp/workspace`.

- [ ] **Step 5: Verify & commit**

Composer validate + all composer fixtures plan/fail as expected; renamed module's three fixtures plan.

```bash
git add -A
git commit -m "refactor(gcp): rename account submodule to workspace

The contract defines the slot by responsibility - everything that registers
the workspace with the Databricks control plane (mws_* here, ARM on Azure).
'account' does not port to Azure, which has no account API layer.

Co-authored-by: Isaac"
```

---

### Task 11: Serverless egress control (C1)

**Files:**
- Create: `modules/gcp/workspace/serverless-egress.tf`
- Modify: `modules/gcp/workspace/variables.tf`, `locals.tf`
- Modify: `modules/gcp/databricks-workspace/variables.tf`, `main.tf`, `preconditions.tf`, `outputs.tf`
- Modify: `modules/gcp/workspace/tests/psc-with-pas/main.tf`, `modules/gcp/databricks-workspace/tests/psc-isolated/main.tf`
- Create: `modules/gcp/databricks-workspace/tests/negative-serverless-destinations/main.tf`
- Modify: `examples/gcp-with-psc-exfiltration-protection/main.tf`, `variables.tf`, `terraform.tfvars`

**Interfaces:**
- Produces (frozen in the contract): composer variables `serverless_egress_mode` (string: `unmanaged|full|restricted`, default `unmanaged`), `serverless_allowed_internet_destinations` (list(string), `[]`), `serverless_allowed_storage_destinations` (list(string), `[]`), `serverless_egress_enforcement` (string: `enforced|dry_run`, default `enforced`); composer output `serverless_network_policy_id`.

- [ ] **Step 1: Workspace-module variables** — append to `modules/gcp/workspace/variables.tf`:

```hcl
variable "google_region" — already present; no change.

variable "serverless_egress_mode" {
  type        = string
  default     = "unmanaged"
  description = "Serverless egress control. unmanaged: no network policy resources; full: policy with FULL_ACCESS; restricted: deny-by-default policy allowing only the listed destinations. Requires the workspace to be on the Enterprise tier"
  validation {
    condition     = contains(["unmanaged", "full", "restricted"], var.serverless_egress_mode)
    error_message = "serverless_egress_mode must be one of: unmanaged, full, restricted."
  }
}

variable "serverless_allowed_internet_destinations" {
  type        = list(string)
  default     = []
  description = "FQDNs serverless workloads may reach when serverless_egress_mode=restricted (max 100)"
}

variable "serverless_allowed_storage_destinations" {
  type        = list(string)
  default     = []
  description = "GCS bucket names serverless workloads may reach when serverless_egress_mode=restricted (max 100); region is taken from google_region"
}

variable "serverless_egress_enforcement" {
  type        = string
  default     = "enforced"
  description = "enforced: violations are blocked; dry_run: violations are only logged (use to evaluate a policy before enforcing)"
  validation {
    condition     = contains(["enforced", "dry_run"], var.serverless_egress_enforcement)
    error_message = "serverless_egress_enforcement must be one of: enforced, dry_run."
  }
}
```

(The first line above is a reminder, not code — `google_region` already exists.)

- [ ] **Step 2: Locals** — append to `modules/gcp/workspace/locals.tf`:

```hcl
  manage_serverless_egress = var.serverless_egress_mode != "unmanaged"
  serverless_restricted    = var.serverless_egress_mode == "restricted"
```

- [ ] **Step 3: Resources** — create `modules/gcp/workspace/serverless-egress.tf`:

```hcl
resource "databricks_account_network_policy" "this" {
  count = local.manage_serverless_egress ? 1 : 0

  network_policy_id = "${var.prefix}-serverless-egress-${var.suffix}"

  egress = {
    network_access = {
      restriction_mode = local.serverless_restricted ? "RESTRICTED_ACCESS" : "FULL_ACCESS"

      allowed_internet_destinations = local.serverless_restricted ? [
        for d in var.serverless_allowed_internet_destinations : {
          destination               = d
          internet_destination_type = "DNS_NAME"
        }
      ] : null

      allowed_storage_destinations = local.serverless_restricted ? [
        for b in var.serverless_allowed_storage_destinations : {
          bucket_name              = b
          region                   = var.google_region
          storage_destination_type = "GOOGLE_CLOUD_STORAGE"
        }
      ] : null

      policy_enforcement = {
        enforcement_mode = var.serverless_egress_enforcement == "dry_run" ? "DRY_RUN" : "ENFORCED"
      }
    }
  }
}

resource "databricks_workspace_network_option" "this" {
  count = local.manage_serverless_egress ? 1 : 0

  workspace_id      = databricks_mws_workspaces.this.workspace_id
  network_policy_id = databricks_account_network_policy.this[0].network_policy_id
}
```

- [ ] **Step 4: Composer plumbing**

- `modules/gcp/databricks-workspace/variables.tf`: append the same four variables verbatim (identical names, types, defaults, validations, descriptions) under a new header `# === Serverless egress control ===========================================`.
- `main.tf` `module "workspace"` block, append:

```hcl
  serverless_egress_mode                   = var.serverless_egress_mode
  serverless_allowed_internet_destinations = var.serverless_allowed_internet_destinations
  serverless_allowed_storage_destinations  = var.serverless_allowed_storage_destinations
  serverless_egress_enforcement            = var.serverless_egress_enforcement
```

- `preconditions.tf`, append inside the lifecycle block:

```hcl
    precondition {
      condition     = var.serverless_egress_mode == "restricted" || (length(var.serverless_allowed_internet_destinations) == 0 && length(var.serverless_allowed_storage_destinations) == 0)
      error_message = "serverless_allowed_internet_destinations and serverless_allowed_storage_destinations require serverless_egress_mode=\"restricted\"."
    }
```

- `modules/gcp/workspace/outputs.tf` and composer `outputs.tf`, append:

```hcl
output "serverless_network_policy_id" {
  value       = local.manage_serverless_egress ? databricks_account_network_policy.this[0].network_policy_id : null
  description = "Serverless egress network-policy ID bound to the workspace (null when serverless_egress_mode=unmanaged)"
}
```

(composer version: `value = module.workspace.serverless_network_policy_id`, no condition needed — the submodule already returns null.)

- [ ] **Step 5: Fixtures**

- `modules/gcp/workspace/tests/psc-with-pas/main.tf`, append to the module block:

```hcl
  serverless_egress_mode                   = "restricted"
  serverless_allowed_internet_destinations = ["pypi.org"]
  serverless_allowed_storage_destinations  = ["fixture-allowed-bucket"]
```

- `modules/gcp/databricks-workspace/tests/psc-isolated/main.tf`, append to the module block:

```hcl
  serverless_egress_mode                   = "restricted"
  serverless_allowed_internet_destinations = ["pypi.org"]
```

- Create `modules/gcp/databricks-workspace/tests/negative-serverless-destinations/main.tf` (same provider header as the other negative fixtures), module block:

```hcl
# precondition fail: destinations without serverless_egress_mode=restricted
module "workspace" {
  source = "../.."

  prefix                = "fixture"
  databricks_account_id = "00000000-0000-0000-0000-000000000000"
  google_project        = "fixture-workspace"
  google_region         = "us-central1"

  vpc_source = "databricks_managed"

  serverless_egress_mode                   = "full"
  serverless_allowed_internet_destinations = ["example.com"]
}
```

- [ ] **Step 6: PSC example**

`examples/gcp-with-psc-exfiltration-protection/variables.tf`, append:

```hcl
variable "serverless_egress_mode" {
  type        = string
  default     = "restricted"
  description = "Serverless egress control mode (unmanaged, full, restricted). Default restricted: deny-by-default for serverless, matching this example's classic-compute posture. Requires Enterprise tier"
}

variable "serverless_allowed_internet_destinations" {
  type        = list(string)
  default     = []
  description = "FQDNs serverless workloads may reach (only with serverless_egress_mode=restricted)"
}

variable "serverless_allowed_storage_destinations" {
  type        = list(string)
  default     = []
  description = "GCS bucket names serverless workloads may reach (only with serverless_egress_mode=restricted)"
}

variable "serverless_egress_enforcement" {
  type        = string
  default     = "enforced"
  description = "enforced or dry_run (log-only evaluation)"
}
```

`main.tf` module block, append the same four pass-throughs as the composer wiring in Step 4. `terraform.tfvars`, append:

```hcl
serverless_egress_mode                   = "restricted"
serverless_allowed_internet_destinations = []
serverless_allowed_storage_destinations  = []
serverless_egress_enforcement            = "enforced"
```

- [ ] **Step 7: Verify & commit**

`psc-with-pas` and `psc-isolated` plans include `databricks_account_network_policy.this[0]` + `databricks_workspace_network_option.this[0]`; the negative fixture fails with the new message; `basic`/`byovpc` plans contain neither resource; PSC example validates.

```bash
git add -A modules/gcp examples/gcp-with-psc-exfiltration-protection
git commit -m "feat(gcp/workspace): serverless egress control via account network policies

Classic-compute egress was hardened while serverless SQL in the same
workspace could egress freely. serverless_egress_mode=restricted creates a
deny-by-default databricks_account_network_policy bound to the workspace;
the PSC example defaults to restricted. Requires Enterprise tier and
databricks provider >= 1.81.1.

Co-authored-by: Isaac"
```

---

### Task 12: CMEK (C2)

**Files:**
- Create: `modules/gcp/workspace/cmek.tf`
- Modify: `modules/gcp/workspace/variables.tf`, `workspace.tf`
- Modify: `modules/gcp/databricks-workspace/variables.tf`, `main.tf`
- Modify: `modules/gcp/databricks-workspace/tests/psc-isolated/main.tf`
- Modify: `examples/gcp-with-psc-exfiltration-protection/variables.tf`, `main.tf`, `terraform.tfvars`

**Interfaces:**
- Produces (frozen concept in the contract; key-reference type is per-cloud): composer variables `cmek_managed_services_key_id`, `cmek_storage_key_id` (string, default null, Cloud KMS key resource IDs like `projects/<p>/locations/<l>/keyRings/<r>/cryptoKeys/<k>`).

- [ ] **Step 1: Variables** — append to `modules/gcp/workspace/variables.tf` AND (verbatim copy) to `modules/gcp/databricks-workspace/variables.tf` under `# === Customer-managed keys (CMEK) =======================================`:

```hcl
variable "cmek_managed_services_key_id" {
  type        = string
  default     = null
  description = "Cloud KMS key resource ID for managed-services CMEK (control-plane data: notebooks, secrets, queries). Null disables. The principal running Terraform needs cloudkms.cryptoKeys.getIamPolicy and setIamPolicy on the key - Databricks sets the key's IAM policy at workspace creation. Enterprise tier; set at creation only"
}

variable "cmek_storage_key_id" {
  type        = string
  default     = null
  description = "Cloud KMS key resource ID for workspace-storage CMEK (GCS buckets and GCE persistent disks). Null disables. Same permission and tier requirements as cmek_managed_services_key_id; set at creation only"
}
```

- [ ] **Step 2: Resources** — create `modules/gcp/workspace/cmek.tf`:

```hcl
resource "databricks_mws_customer_managed_keys" "managed_services" {
  count = var.cmek_managed_services_key_id != null ? 1 : 0

  gcp_key_info {
    kms_key_id = var.cmek_managed_services_key_id
  }
  use_cases = ["MANAGED_SERVICES"]
}

resource "databricks_mws_customer_managed_keys" "storage" {
  count = var.cmek_storage_key_id != null ? 1 : 0

  gcp_key_info {
    kms_key_id = var.cmek_storage_key_id
  }
  use_cases = ["STORAGE"]
}
```

- [ ] **Step 3: Wire into the workspace** — in `modules/gcp/workspace/workspace.tf`, add after `private_access_settings_id`:

```hcl
  managed_services_customer_managed_key_id = var.cmek_managed_services_key_id != null ? databricks_mws_customer_managed_keys.managed_services[0].customer_managed_key_id : null
  storage_customer_managed_key_id          = var.cmek_storage_key_id != null ? databricks_mws_customer_managed_keys.storage[0].customer_managed_key_id : null
```

- [ ] **Step 4: Composer wiring** — `main.tf` `module "workspace"` block, append:

```hcl
  cmek_managed_services_key_id = var.cmek_managed_services_key_id
  cmek_storage_key_id          = var.cmek_storage_key_id
```

- [ ] **Step 5: Fixture + example**

- `modules/gcp/databricks-workspace/tests/psc-isolated/main.tf`, append to the module block:

```hcl
  cmek_managed_services_key_id = "projects/fixture-workspace/locations/us-central1/keyRings/fixture-kr/cryptoKeys/fixture-ms-key"
  cmek_storage_key_id          = "projects/fixture-workspace/locations/us-central1/keyRings/fixture-kr/cryptoKeys/fixture-storage-key"
```

- PSC example: append the two variables (verbatim from Step 1) to `variables.tf`, the two pass-through lines to `main.tf`, and to `terraform.tfvars`:

```hcl
cmek_managed_services_key_id = null
cmek_storage_key_id          = null
```

- [ ] **Step 6: Verify & commit**

`psc-isolated` plan includes both `databricks_mws_customer_managed_keys` resources and the two key args on `databricks_mws_workspaces.this`; `basic` plan includes neither; example validates.

```bash
git add -A modules/gcp examples/gcp-with-psc-exfiltration-protection
git commit -m "feat(gcp/workspace): optional CMEK for managed services and workspace storage

Cloud KMS keys wire through databricks_mws_customer_managed_keys into the
workspace at creation. No Terraform-side IAM grants: Databricks sets the
key IAM policy during workspace creation, which is why the Terraform
principal needs cloudkms.cryptoKeys.get/setIamPolicy on the key.

Co-authored-by: Isaac"
```

---

### Task 13: Remove GKE pod/svc secondary ranges (C3)

**Files:**
- Modify: `modules/gcp/network/variables.tf`, `subnets.tf`
- Modify: `modules/gcp/databricks-workspace/variables.tf`, `main.tf`
- Modify: `examples/gcp-byovpc/variables.tf`, `main.tf`, `terraform.tfvars`

- [ ] **Step 1: Network module** — delete `variable "pod_cidr"` and `variable "svc_cidr"` from `modules/gcp/network/variables.tf`; delete both `dynamic "secondary_ip_range"` blocks from `subnets.tf`.

- [ ] **Step 2: Composer** — delete `variable "pod_cidr"` and `variable "svc_cidr"` from `variables.tf`; delete `pod_cidr = var.pod_cidr` and `svc_cidr = var.svc_cidr` from the `module "network"` block in `main.tf`.

- [ ] **Step 3: BYOVPC example** — delete the `pod_cidr`/`svc_cidr` variables from `variables.tf`, the two pass-through lines from `main.tf`, and the `pod_cidr = null` / `svc_cidr = null` lines from `terraform.tfvars`. In `variables.tf` change the `subnet_cidr` description to `"CIDR for the workspace subnet primary range (e.g. 10.0.0.0/22)"`.

- [ ] **Step 4: Verify & commit**

`grep -rn "pod_cidr\|svc_cidr" modules examples` returns nothing; network/composer validates; `byovpc` fixtures and example plan/validate.

```bash
git add -A modules/gcp examples/gcp-byovpc
git commit -m "refactor(gcp/network)!: drop GKE pod/svc secondary IP ranges

The GCP data plane runs on GCE; BYOVPC requires exactly one subnet and no
secondary ranges. BREAKING: GKE-era configs must remove pod_cidr/svc_cidr.

Co-authored-by: Isaac"
```

---

### Task 14: Shared security-settings module (C4)

Cloud-neutral module (identical resources on every cloud) — first resident of `modules/databricks/`. Takes a **workspace-level** databricks provider from the caller; never called by the composer.

**Files:**
- Create: `modules/databricks/Makefile`, `modules/databricks/security-settings/{versions.tf,variables.tf,preconditions.tf,csp.tf,esm.tf,acu.tf,ip-access-lists.tf,outputs.tf,README.md,Makefile}`
- Create: `modules/databricks/security-settings/tests/all-enabled/main.tf`
- Modify: `modules/Makefile`
- Create: `examples/gcp-with-psc-exfiltration-protection/security-settings.tf`
- Modify: `examples/gcp-with-psc-exfiltration-protection/variables.tf`, `terraform.tfvars`

- [ ] **Step 1: Module scaffolding**

`modules/databricks/security-settings/versions.tf`:

```hcl
terraform {
  required_version = ">= 1.5"
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = ">= 1.81.1"
    }
  }
}
```

`variables.tf`:

```hcl
variable "enable_compliance_security_profile" {
  type        = bool
  default     = false
  description = "Enable the Compliance Security Profile on the workspace. WARNING: irreversible - CSP cannot be disabled once enabled. Requires enable_enhanced_security_monitoring=true"
}

variable "compliance_standards" {
  type        = list(string)
  default     = []
  description = "Compliance standards for the CSP (e.g. [\"HIPAA\"]). Only meaningful when enable_compliance_security_profile=true"
}

variable "enable_enhanced_security_monitoring" {
  type        = bool
  default     = false
  description = "Enable Enhanced Security Monitoring (hardened images, monitoring agents)"
}

variable "enable_automatic_cluster_update" {
  type        = bool
  default     = false
  description = "Enable automatic cluster update for the workspace"
}

variable "ip_access_lists" {
  type = list(object({
    label        = string
    list_type    = string
    ip_addresses = list(string)
  }))
  default     = []
  description = "Workspace IP access lists. list_type is ALLOW or BLOCK. A non-empty list also flips the enableIpAccessLists workspace conf"
  validation {
    condition     = alltrue([for l in var.ip_access_lists : contains(["ALLOW", "BLOCK"], l.list_type)])
    error_message = "ip_access_lists[*].list_type must be ALLOW or BLOCK."
  }
}
```

`preconditions.tf`:

```hcl
resource "terraform_data" "preconditions" {
  lifecycle {
    precondition {
      condition     = !var.enable_compliance_security_profile || var.enable_enhanced_security_monitoring
      error_message = "enable_compliance_security_profile=true requires enable_enhanced_security_monitoring=true (CSP builds on ESM)."
    }
    precondition {
      condition     = length(var.compliance_standards) == 0 || var.enable_compliance_security_profile
      error_message = "compliance_standards requires enable_compliance_security_profile=true."
    }
  }
}
```

`csp.tf`:

```hcl
resource "databricks_compliance_security_profile_setting" "this" {
  count = var.enable_compliance_security_profile ? 1 : 0

  compliance_security_profile_workspace {
    is_enabled           = true
    compliance_standards = var.compliance_standards
  }
}
```

`esm.tf`:

```hcl
resource "databricks_enhanced_security_monitoring_setting" "this" {
  count = var.enable_enhanced_security_monitoring ? 1 : 0

  enhanced_security_monitoring_workspace {
    is_enabled = true
  }
}
```

`acu.tf`:

```hcl
resource "databricks_automatic_cluster_update_setting" "this" {
  count = var.enable_automatic_cluster_update ? 1 : 0

  automatic_cluster_update_workspace {
    enabled = true
  }
}
```

`ip-access-lists.tf`:

```hcl
resource "databricks_workspace_conf" "enable_ip_access_lists" {
  count = length(var.ip_access_lists) > 0 ? 1 : 0

  custom_config = {
    "enableIpAccessLists" = "true"
  }
}

resource "databricks_ip_access_list" "this" {
  for_each = { for l in var.ip_access_lists : l.label => l }

  label        = each.value.label
  list_type    = each.value.list_type
  ip_addresses = each.value.ip_addresses

  depends_on = [databricks_workspace_conf.enable_ip_access_lists]
}
```

`outputs.tf`:

```hcl
# This module has no outputs; settings are terminal.
```

`Makefile` (copy of `modules/gcp/network/Makefile` — the standard terraform-docs recipe used by every module in this repo).

`README.md`:

```markdown
# modules/databricks/security-settings

Cloud-neutral workspace security settings: Compliance Security Profile,
Enhanced Security Monitoring, automatic cluster update, and IP access lists.
Takes a workspace-level databricks provider from the caller.

> WARNING: the Compliance Security Profile cannot be disabled once enabled.

## Usage

```hcl
module "security_settings" {
  source = "github.com/databricks/terraform-databricks-examples//modules/databricks/security-settings"

  providers = {
    databricks = databricks.workspace
  }

  enable_enhanced_security_monitoring = true
  enable_compliance_security_profile  = true
  compliance_standards                = ["HIPAA"]
}
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
```

If `terraform validate` rejects any nested block name on the three settings resources, check the provider docs (`docs/resources/compliance_security_profile_setting.md`, `enhanced_security_monitoring_setting.md`, `automatic_cluster_update_setting.md` in databricks/terraform-provider-databricks) and use the documented block name — the resource set and gating logic stay as written.

- [ ] **Step 2: Makefile recursion**

`modules/databricks/Makefile` — same content as `modules/gcp/Makefile`:

```make
PROJECTS := $(dir $(wildcard */README.md))

docs: $(PROJECTS)

$(PROJECTS):
	$(MAKE) -C $@ docs

.PHONY: $(PROJECTS) docs
```

`modules/Makefile` — add a `databricks-recursive` target mirroring `gcp-recursive`:

```make
PROJECTS := $(dir $(wildcard */README.md))

docs: $(PROJECTS) gcp-recursive databricks-recursive

$(PROJECTS):
	$(MAKE) -C $@ docs

gcp-recursive:
	$(MAKE) -C gcp docs

databricks-recursive:
	$(MAKE) -C databricks docs

.PHONY: $(PROJECTS) docs gcp-recursive databricks-recursive
```

- [ ] **Step 3: Fixture** — `modules/databricks/security-settings/tests/all-enabled/main.tf`:

```hcl
terraform {
  required_version = ">= 1.5"
  required_providers {
    databricks = { source = "databricks/databricks" }
  }
}

provider "databricks" {
  host  = "https://1234567890123456.7.gcp.databricks.com"
  token = "fixture-token"
}

module "security_settings" {
  source = "../.."

  enable_enhanced_security_monitoring = true
  enable_compliance_security_profile  = true
  compliance_standards                = ["HIPAA"]
  enable_automatic_cluster_update     = true

  ip_access_lists = [
    {
      label        = "corp-vpn"
      list_type    = "ALLOW"
      ip_addresses = ["203.0.113.0/24"]
    }
  ]
}
```

- [ ] **Step 4: Wire into the PSC example**

`examples/gcp-with-psc-exfiltration-protection/security-settings.tf`:

```hcl
module "security_settings" {
  source = "../../modules/databricks/security-settings"

  providers = {
    databricks = databricks.workspace
  }

  enable_compliance_security_profile  = var.enable_compliance_security_profile
  compliance_standards                = var.compliance_standards
  enable_enhanced_security_monitoring = var.enable_enhanced_security_monitoring
  enable_automatic_cluster_update     = var.enable_automatic_cluster_update
  ip_access_lists                     = var.ip_access_lists

  depends_on = [module.workspace]
}
```

`variables.tf`, append the five variables verbatim from Step 1 (same names/types/defaults/descriptions). `terraform.tfvars`, append:

```hcl
enable_compliance_security_profile  = false
compliance_standards                = []
enable_enhanced_security_monitoring = false
enable_automatic_cluster_update     = false
ip_access_lists                     = []
```

- [ ] **Step 5: Verify & commit**

Module validate passes; `tests/all-enabled` plans 5 resources (CSP, ESM, ACU, workspace_conf, one ip_access_list) plus `terraform_data.preconditions`; PSC example validates; a temporary edit of the fixture to `enable_enhanced_security_monitoring = false` fails plan with the CSP⇒ESM message (revert after checking).

```bash
git add modules/databricks modules/Makefile examples/gcp-with-psc-exfiltration-protection
git commit -m "feat(databricks/security-settings): shared workspace security-settings module

Cloud-neutral module (CSP, ESM, automatic cluster update, IP access lists)
under the new modules/databricks/ namespace; wired into the PSC example via
the workspace-level provider alias. CSP is irreversible and precondition-
gated on ESM.

Co-authored-by: Isaac"
```

---

### Task 15: Cross-cloud module contract document

**Files:**
- Create: `docs/cross-cloud-module-contract.md`

- [ ] **Step 1: Write the document** with exactly these sections (prose may be refined, normative content must match):

```markdown
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
| Endpoint IP outputs | `frontend_psc_ip_<spoke|hub>` | `frontend_endpoint_ip_<spoke|hub>` | n/a (ENI-based) |

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
  that completes `terraform plan` offline; each precondition has a
  `tests/negative-*` fixture that fails plan with the expected message.
- Submodules carry per-scenario plan fixtures.
```

- [ ] **Step 2: Commit**

```bash
git add docs/cross-cloud-module-contract.md
git commit -m "docs: add cross-cloud module contract

Freezes the module slots, composer interface, two-tier naming rule, file
shape and testing standard that Azure/AWS refactors must follow; the GCP
tree is the reference implementation.

Co-authored-by: Isaac"
```

---

### Task 16: terraform-docs regen, README refresh, PR update

**Files:**
- Modify: all `modules/gcp/*/README.md`, `modules/databricks/security-settings/README.md` (generated)
- Modify: repo root `README.md`
- Modify: PR #233 title/body (via `gh`) — **CHECKPOINT-gated**

- [ ] **Step 1: Regenerate docs**

```bash
make -C modules/gcp docs
make -C modules/databricks docs
git status --short   # confirm only README.md files under modules/ changed
```

- [ ] **Step 2: Root README** — in the GCP modules list: rename the `account` entry to `workspace`, add `modules/databricks/security-settings`, and ensure the four examples are listed. Keep the existing table format.

- [ ] **Step 3: Full-tree verification sweep**

```bash
terraform fmt -recursive -check modules examples
for d in modules/gcp/network modules/gcp/private-connectivity modules/gcp/workspace modules/gcp/dns modules/gcp/databricks-workspace modules/gcp/service-account modules/gcp/unity-catalog modules/databricks/security-settings examples/gcp-basic examples/gcp-byovpc examples/gcp-existing-vpc examples/gcp-with-psc-exfiltration-protection examples/gcp-sa-provisioning; do
  (cd $d && terraform init -backend=false -upgrade >/dev/null && terraform validate) || echo "FAIL: $d"
done
```

All positive fixtures plan; all 7 negative fixtures fail with their messages. Record actual results.

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "docs(gcp): regenerate terraform-docs and refresh READMEs

Co-authored-by: Isaac"
```

- [ ] **Step 5: CHECKPOINT — user approval required**

STOP. Present to Michele: the commit list, the verification sweep results, and the proposed updated PR body (rewrite of the current #233 description reflecting: the fixed findings, the flag-equality dialect rule, the rename, the contract doc, the four features, the corrected test-plan checklist with Phase B items unchecked). Only after approval:

```bash
git push origin feature/gcp-modules-refactor
gh pr edit 233 --title "feat(gcp): composer + submodules refactor, hardening fixes, cross-cloud contract, serverless egress & CMEK" --body-file <approved-body-file>
```

Do NOT append any AI-attribution footer to the PR body (Michele's standing preference).

---

### Task 17: Phase B — GCP sandbox verification (manual, blocked on user)

Requires Michele's sandbox project + credentials (`! gcloud auth login`, plus `databricks_google_service_account` with account-admin delegation). Record every result in the PR test-plan checklist.

- [ ] **Step 1: gcp-basic** — fill `examples/gcp-basic/terraform.tfvars`, `terraform init && terraform apply`; workspace URL reachable, log in; `terraform destroy`.
- [ ] **Step 2: gcp-byovpc** — apply; confirm workspace up AND that Databricks created the `db-<subnet>-ingress`/`-egress` firewall rules in the spoke project (`gcloud compute firewall-rules list --filter="name~db-"`); destroy.
- [ ] **Step 3: PSC example** — apply `examples/gcp-with-psc-exfiltration-protection` with `serverless_egress_mode=restricted`. Checks, in order:
  1. `terraform apply` completes (validates Task 1 static counts against the real API).
  2. Workspace URL resolves to the PSC IP from a hub-network VM and is NOT reachable from the public internet (PAS `public_access_enabled=false`).
  3. Launch the smallest cluster (`databricks clusters create --json '{"cluster_name":"smoke","spark_version":"<latest LTS from databricks clusters spark-versions>","node_type_id":"n2-standard-4","num_workers":1,"autotermination_minutes":15}'`) and run a notebook command — this validates Task 2 (spoke DNS) and Task 3 (intra-VPC firewall): cluster reaches RUNNING and executes.
  4. In a SQL warehouse (serverless), attempt `curl example.com` equivalent via an external location or `requests` in a serverless notebook — expect the network policy to deny; check the policy's denial log in the account console.
  5. UC attach from `unity-catalog.tf` works (catalog visible in the workspace).
  6. `terraform destroy` completes cleanly.
- [ ] **Step 4:** Update the PR test-plan checkboxes with actual results (through the Task 16 checkpoint process if the PR body needs edits).

---

## Self-Review Log

- Spec coverage: A1→T1, A2→T2, A3→T3, A4/A5+A6→T4, A7→T5, A8→T6, A9→T7, A10/A11→T8, A12/A13→T9, rename→T10, C1→T11, C2→T12, C3→T13, C4→T14, contract→T15, docs/PR→T16, Phase B→T17. NCC slot-only lives in the contract (T15 §1 reserved row). No gaps.
- Type consistency: `create_hub` bool in both submodules (T1) matches composer wiring; `serverless_*`/`cmek_*` names identical across workspace module, composer, example (T11/T12); `module.workspace.*` refs post-rename (T10) used by T11/T12 file paths.
- Placeholders: none; every code step carries full content. The two "if validate fails, consult provider docs" fallbacks (T8 Step 4, T14 Step 1) are deliberate contingencies with defined behavior, not gaps.
```
