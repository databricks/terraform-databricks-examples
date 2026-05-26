# GCP Best-Practices Refactor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Polish the GCP modules and examples landed in PR #233: fill ~70 missing variable descriptions, split large `main.tf` files by concern, standardize `versions.tf` placement, expand composer outputs, fix output misnomers, add region validations, and add README usage examples — without changing runtime behavior.

**Architecture:** Eight focused commits, each leaving the tree validating. The composer-side rename (`*_psc_fr_id` → `*_forwarding_rule_name`) is coordinated across `private-connectivity` outputs, `account` inputs, and composer wiring in a single commit to avoid an intermediate broken state.

**Tech Stack:** Terraform >= 1.5, existing `hashicorp/google` + `databricks/databricks` + `hashicorp/random` + `hashicorp/null` providers, `terraform-docs`, `pre-commit`.

**Spec reference:** `docs/superpowers/specs/2026-05-26-gcp-best-practices-refactor-design.md`

**Branch:** `feature/gcp-modules-refactor` (continues on draft PR #233; do not push, do not open new PRs)

---

## File Structure

This plan operates on existing files. The summary of what each task touches:

```
modules/gcp/
├── network/
│   ├── main.tf            DELETE  (contents move to per-concern files)
│   ├── vpc.tf             NEW     (Task 1)
│   ├── subnets.tf         NEW     (Task 1)
│   ├── nat.tf             NEW     (Task 1)
│   ├── peering.tf         NEW     (Task 1)
│   ├── shared-vpc.tf      NEW     (Task 1)
│   ├── data.tf            NEW     (Task 1)
│   ├── locals.tf          NEW     (Task 1)
│   ├── variables.tf       (unchanged — already documented)
│   ├── outputs.tf         (unchanged)
│   └── versions.tf        (unchanged)
├── private-connectivity/
│   ├── psc.tf             (unchanged)
│   ├── firewall.tf        (unchanged)
│   ├── locals.tf          (unchanged)
│   ├── variables.tf       MODIFY (Task 4 — descriptions, Task 5 — region validation)
│   ├── outputs.tf         MODIFY (Task 2 — rename *_fr_id → *_forwarding_rule_name)
│   ├── versions.tf        (unchanged)
│   └── README.md          MODIFY (Task 7 — Usage block; Task 8 — terraform-docs regen)
├── account/
│   ├── main.tf            DELETE  (contents move to workspace.tf + networks.tf + locals.tf)
│   ├── workspace.tf       NEW     (Task 1)
│   ├── networks.tf        NEW     (Task 1)
│   ├── locals.tf          NEW     (Task 1)
│   ├── vpc-endpoints.tf   (unchanged)
│   ├── pas.tf             (unchanged)
│   ├── variables.tf       MODIFY (Task 2 — rename inputs; Task 4 — descriptions)
│   ├── outputs.tf         MODIFY (Task 3 — add private_access_settings_id)
│   ├── versions.tf        (unchanged)
│   └── README.md          MODIFY (Task 7; Task 8)
├── dns/
│   ├── hub.tf             MODIFY (Task 1 — extract workspace_dns_id into locals.tf)
│   ├── spoke.tf           (unchanged)
│   ├── locals.tf          NEW     (Task 1)
│   ├── variables.tf       MODIFY (Task 4 — descriptions)
│   ├── outputs.tf         (unchanged)
│   ├── versions.tf        (unchanged)
│   └── README.md          MODIFY (Task 7; Task 8)
├── databricks-workspace/
│   ├── main.tf            REWRITE (Task 1 — only module blocks remain)
│   ├── locals.tf          NEW     (Task 1)
│   ├── preconditions.tf   NEW     (Task 1 — also adds region precondition in Task 5)
│   ├── random.tf          NEW     (Task 1)
│   ├── variables.tf       MODIFY (Task 4 — descriptions)
│   ├── outputs.tf         REWRITE (Task 3 — drop vpc_id, add 14 outputs, explicit ternaries)
│   ├── versions.tf        (unchanged)
│   └── README.md          MODIFY (Task 7; Task 8)
├── service-account/
│   ├── init.tf            DELETE  (Task 6 — split into versions.tf; provider block removed)
│   ├── versions.tf        NEW     (Task 6)
│   ├── main.tf            (unchanged)
│   ├── variables.tf       MODIFY (Task 4 — descriptions if missing)
│   ├── outputs.tf         (unchanged)
│   └── README.md          MODIFY (Task 7; Task 8)
└── unity-catalog/
    ├── terraform.tf       RENAME → versions.tf  (Task 6)
    ├── databricks-cloud-resources.tf  (unchanged)
    ├── gcs.tf             (unchanged)
    ├── variables.tf       MODIFY (Task 4 if any are undocumented)
    └── README.md          MODIFY (Task 7; Task 8)

examples/
├── gcp-basic/
│   ├── init.tf            DELETE (Task 6 — split)
│   ├── versions.tf        NEW    (Task 6)
│   ├── providers.tf       NEW    (Task 6)
│   └── (other files unchanged)
├── gcp-byovpc/            (same pattern)
├── gcp-existing-vpc/      (same pattern)
├── gcp-with-psc-exfiltration-protection/
│   └── terraform.tf       RENAME → versions.tf  (Task 6)
└── gcp-sa-provisioning/
    ├── init.tf            DELETE (Task 6 — split; google provider block now lives here, not in the module)
    ├── versions.tf        NEW    (Task 6)
    └── providers.tf       NEW    (Task 6)
```

The 8 tasks below correspond to the 8 commits in the spec's "Implementation phasing" section, in order:

1. **Task 1:** Split module files by concern (no behavioral change)
2. **Task 2:** Rename forwarding-rule outputs in `private-connectivity` and inputs in `account` (coordinated)
3. **Task 3:** Expand and rename composer outputs (drop `vpc_id`, add 14 outputs, switch `try()` to explicit ternaries)
4. **Task 4:** Add `description` to ~70 variables across 5 modules
5. **Task 5:** Add region validations on `private-connectivity` and composer
6. **Task 6:** Standardize provider/versions placement across modules and examples
7. **Task 7:** Add `## Usage` sections to module READMEs
8. **Task 8:** Regenerate terraform-docs READMEs across all modules

---

## Conventions for every task

- **No `.terraform/` cleanup needed**: existing `.gitignore` already excludes `.terraform/` and `.terraform.lock.hcl`. They won't appear in commits.
- **`make docs` must only be run from inside a specific module directory**, never from the repo root or `modules/`. Running it higher up regenerates non-GCP READMEs and creates drift.
- **Validate after every code change**: `cd <module-or-example-dir> && terraform init -backend=false && terraform validate`. Required to pass before commit.
- **Commit messages use the Co-authored-by: Isaac trailer** per the project commit template.
- **Do not push the branch.** Pushing/PR-management happens after all tasks complete and the user reviews.

---

## Task 1: Split module files by concern

**Goal:** Reorganize `network`, `account`, `dns`, and `databricks-workspace` (composer) into focused single-concern files. No resource attributes change; only file boundaries.

**Files:**

In `modules/gcp/network/`:
- Delete: `main.tf`
- Create: `vpc.tf`, `subnets.tf`, `nat.tf`, `peering.tf`, `shared-vpc.tf`, `data.tf`, `locals.tf`

In `modules/gcp/account/`:
- Delete: `main.tf`
- Create: `workspace.tf`, `networks.tf`, `locals.tf`

In `modules/gcp/dns/`:
- Modify: `hub.tf` (remove the `locals { workspace_dns_id = ... }` block)
- Create: `locals.tf`

In `modules/gcp/databricks-workspace/`:
- Rewrite: `main.tf` (only the 4 module blocks remain)
- Create: `locals.tf`, `preconditions.tf`, `random.tf`

- [ ] **Step 1: Create `modules/gcp/network/locals.tf`**

```hcl
locals {
  create_vpc       = var.vpc_source == "create"
  use_existing_vpc = var.vpc_source == "existing"

  subnet_name = coalesce(var.subnet_name, "${var.prefix}-subnet-${var.suffix}")
}
```

- [ ] **Step 2: Create `modules/gcp/network/vpc.tf`**

```hcl
# === Spoke VPC (created) ================================================
resource "google_compute_network" "spoke_vpc" {
  count = local.create_vpc ? 1 : 0

  name                    = "${var.prefix}-spoke-vpc-${var.suffix}"
  project                 = var.spoke_vpc_google_project
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
}

# === Hub VPC ============================================================
resource "google_compute_network" "hub_vpc" {
  count = var.create_hub ? 1 : 0

  name                    = "${var.prefix}-hub-vpc-${var.suffix}"
  project                 = var.hub_vpc_google_project
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
}
```

- [ ] **Step 3: Create `modules/gcp/network/subnets.tf`**

```hcl
# === Spoke subnet =======================================================
resource "google_compute_subnetwork" "spoke_subnet" {
  count = local.create_vpc ? 1 : 0

  name                     = local.subnet_name
  project                  = var.spoke_vpc_google_project
  network                  = google_compute_network.spoke_vpc[0].id
  region                   = var.google_region
  ip_cidr_range            = var.subnet_cidr
  private_ip_google_access = true

  dynamic "secondary_ip_range" {
    for_each = var.pod_cidr != null ? [1] : []
    content {
      range_name    = "pods"
      ip_cidr_range = var.pod_cidr
    }
  }

  dynamic "secondary_ip_range" {
    for_each = var.svc_cidr != null ? [1] : []
    content {
      range_name    = "services"
      ip_cidr_range = var.svc_cidr
    }
  }
}

# === Hub subnet =========================================================
resource "google_compute_subnetwork" "hub_subnet" {
  count = var.create_hub ? 1 : 0

  name                     = "${var.prefix}-hub-subnet-${var.suffix}"
  project                  = var.hub_vpc_google_project
  network                  = google_compute_network.hub_vpc[0].id
  region                   = var.google_region
  ip_cidr_range            = var.hub_vpc_cidr
  private_ip_google_access = true
}
```

- [ ] **Step 4: Create `modules/gcp/network/nat.tf`**

```hcl
resource "google_compute_router" "router" {
  count = local.create_vpc ? 1 : 0

  name    = "${var.prefix}-router-${var.suffix}"
  project = var.spoke_vpc_google_project
  region  = var.google_region
  network = google_compute_network.spoke_vpc[0].id
}

resource "google_compute_router_nat" "nat" {
  count = local.create_vpc ? 1 : 0

  name                               = "${var.prefix}-nat-${var.suffix}"
  project                            = var.spoke_vpc_google_project
  router                             = google_compute_router.router[0].name
  region                             = var.google_region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
```

- [ ] **Step 5: Create `modules/gcp/network/peering.tf`**

```hcl
resource "google_compute_network_peering" "hub_to_spoke" {
  count = var.create_hub ? 1 : 0

  name         = "${var.prefix}-hub-spoke-${var.suffix}"
  network      = google_compute_network.hub_vpc[0].self_link
  peer_network = local.create_vpc ? google_compute_network.spoke_vpc[0].self_link : data.google_compute_network.existing_spoke[0].self_link
}

resource "google_compute_network_peering" "spoke_to_hub" {
  count = var.create_hub ? 1 : 0

  name         = "${var.prefix}-spoke-hub-${var.suffix}"
  network      = local.create_vpc ? google_compute_network.spoke_vpc[0].self_link : data.google_compute_network.existing_spoke[0].self_link
  peer_network = google_compute_network.hub_vpc[0].self_link
}
```

- [ ] **Step 6: Create `modules/gcp/network/shared-vpc.tf`**

```hcl
resource "google_compute_shared_vpc_host_project" "host" {
  count = var.create_hub && var.is_spoke_vpc_shared && var.workspace_google_project != var.spoke_vpc_google_project ? 1 : 0

  project = var.spoke_vpc_google_project
}

resource "google_compute_shared_vpc_service_project" "service" {
  count = var.create_hub && var.is_spoke_vpc_shared && var.workspace_google_project != var.spoke_vpc_google_project ? 1 : 0

  host_project    = google_compute_shared_vpc_host_project.host[0].project
  service_project = var.workspace_google_project
}
```

- [ ] **Step 7: Create `modules/gcp/network/data.tf`**

```hcl
data "google_compute_network" "existing_spoke" {
  count = local.use_existing_vpc ? 1 : 0

  name    = var.existing_vpc_name
  project = var.spoke_vpc_google_project
}

data "google_compute_subnetwork" "existing_spoke_subnet" {
  count = local.use_existing_vpc ? 1 : 0

  name    = var.existing_subnet_name
  project = var.spoke_vpc_google_project
  region  = var.google_region
}
```

- [ ] **Step 8: Delete `modules/gcp/network/main.tf`**

```bash
git rm modules/gcp/network/main.tf
```

- [ ] **Step 9: Validate the network module**

```bash
cd modules/gcp/network && terraform init -backend=false && terraform validate
```

Expected: `Success! The configuration is valid.`

Also validate each fixture:

```bash
for d in tests/create tests/existing tests/create-with-hub; do
  cd modules/gcp/network/$d && terraform init -backend=false && terraform validate && cd -
done
```

Each should print `Success!`.

- [ ] **Step 10: Create `modules/gcp/account/locals.tf`**

```hcl
locals {
  workspace_name     = coalesce(var.workspace_name, "${var.prefix}-ws-${var.suffix}")
  emit_mws_networks  = var.vpc_source != "databricks_managed"
  emit_vpc_endpoints = var.frontend_psc_fr_id != null && var.backend_psc_fr_id != null
  emit_pas           = var.private_access_only
}
```

(Note: variable references here are pre-rename — they get updated in Task 2.)

- [ ] **Step 11: Create `modules/gcp/account/workspace.tf`**

```hcl
resource "databricks_mws_workspaces" "this" {
  account_id     = var.databricks_account_id
  workspace_name = local.workspace_name
  location       = var.google_region

  cloud_resource_container {
    gcp {
      project_id = var.google_project
    }
  }

  network_id                 = local.emit_mws_networks ? databricks_mws_networks.this[0].network_id : null
  private_access_settings_id = local.emit_pas ? databricks_mws_private_access_settings.this[0].private_access_settings_id : null

  token {
    comment = "Terraform"
  }

  depends_on = [var.nat_dependency]
}
```

- [ ] **Step 12: Create `modules/gcp/account/networks.tf`**

```hcl
resource "databricks_mws_networks" "this" {
  count = local.emit_mws_networks ? 1 : 0

  account_id   = var.databricks_account_id
  network_name = "${var.prefix}-ntw-${var.suffix}"

  gcp_network_info {
    network_project_id = var.spoke_vpc_google_project
    vpc_id             = var.spoke_vpc_name
    subnet_id          = var.spoke_subnet_name
    subnet_region      = var.google_region
  }

  dynamic "vpc_endpoints" {
    for_each = local.emit_vpc_endpoints ? [1] : []
    content {
      dataplane_relay = [databricks_mws_vpc_endpoint.backend[0].vpc_endpoint_id]
      rest_api        = [databricks_mws_vpc_endpoint.frontend[0].vpc_endpoint_id]
    }
  }
}
```

- [ ] **Step 13: Delete `modules/gcp/account/main.tf`**

```bash
git rm modules/gcp/account/main.tf
```

- [ ] **Step 14: Validate the account module**

```bash
cd modules/gcp/account && terraform init -backend=false && terraform validate
```

Expected: `Success! The configuration is valid.`

Also validate the three fixtures:

```bash
for d in tests/databricks-managed tests/byovpc tests/psc-with-pas; do
  cd modules/gcp/account/$d && terraform init -backend=false && terraform validate && cd -
done
```

- [ ] **Step 15: Create `modules/gcp/dns/locals.tf`**

```hcl
locals {
  # Regex extracts the workspace DNS id (numeric.numeric) from the URL.
  workspace_dns_id = regex("[0-9]+\\.[0-9]+", var.workspace_url)
}
```

- [ ] **Step 16: Remove the `locals` block from `modules/gcp/dns/hub.tf`**

Use the Edit tool on `modules/gcp/dns/hub.tf` to remove lines 1-4 (the `locals` block at the top). The file should now start with the first DNS managed zone resource. Concretely, delete:

```hcl
locals {
  # Regex extracts the workspace DNS id (numeric.numeric) from the URL.
  workspace_dns_id = regex("[0-9]+\\.[0-9]+", var.workspace_url)
}

```

(Including the blank line after the closing brace.)

- [ ] **Step 17: Validate the dns module**

```bash
cd modules/gcp/dns && terraform init -backend=false && terraform validate
cd modules/gcp/dns/tests/hub-and-spoke && terraform init -backend=false && terraform validate
```

Expected: both `Success!`.

- [ ] **Step 18: Create `modules/gcp/databricks-workspace/locals.tf`**

```hcl
locals {
  databricks_managed = var.vpc_source == "databricks_managed"
  create_vpc         = var.vpc_source == "create"
  use_existing_vpc   = var.vpc_source == "existing"

  any_private_link = var.private_link_frontend || var.private_link_backend
  spoke_project    = coalesce(var.spoke_vpc_google_project, var.google_project)
}
```

- [ ] **Step 19: Create `modules/gcp/databricks-workspace/random.tf`**

```hcl
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false

  lifecycle {
    ignore_changes = [special, upper]
  }
}
```

- [ ] **Step 20: Create `modules/gcp/databricks-workspace/preconditions.tf`**

```hcl
# Cross-variable preconditions.
resource "null_resource" "preconditions" {
  lifecycle {
    precondition {
      condition     = !var.restricted_egress || local.create_vpc
      error_message = "restricted_egress=true requires vpc_source=\"create\" (hub-spoke topology needs us to own both VPCs)."
    }
    precondition {
      condition     = !var.restricted_egress || local.any_private_link
      error_message = "restricted_egress=true requires at least one of private_link_frontend or private_link_backend."
    }
    precondition {
      condition     = !var.restricted_egress || (var.hub_vpc_google_project != null && var.hub_vpc_cidr != null && var.psc_subnet_cidr != null)
      error_message = "restricted_egress=true requires hub_vpc_google_project, hub_vpc_cidr, and psc_subnet_cidr."
    }
    precondition {
      condition     = !local.create_vpc || (var.spoke_vpc_cidr != null && var.subnet_cidr != null)
      error_message = "vpc_source=\"create\" requires spoke_vpc_cidr and subnet_cidr."
    }
    precondition {
      condition     = !local.use_existing_vpc || (var.existing_vpc_name != null && var.existing_subnet_name != null)
      error_message = "vpc_source=\"existing\" requires existing_vpc_name and existing_subnet_name."
    }
    precondition {
      condition     = !local.databricks_managed || (!var.private_link_frontend && !var.private_link_backend && !var.restricted_egress)
      error_message = "vpc_source=\"databricks_managed\" forbids private_link_frontend, private_link_backend, and restricted_egress."
    }
  }
}
```

- [ ] **Step 21: Rewrite `modules/gcp/databricks-workspace/main.tf` to only contain module blocks**

Replace the entire file content with:

```hcl
module "network" {
  source = "../network"
  count  = local.databricks_managed ? 0 : 1

  prefix                   = var.prefix
  suffix                   = random_string.suffix.result
  google_region            = var.google_region
  vpc_source               = var.vpc_source
  spoke_vpc_google_project = local.spoke_project

  spoke_vpc_cidr = var.spoke_vpc_cidr
  subnet_cidr    = var.subnet_cidr
  pod_cidr       = var.pod_cidr
  svc_cidr       = var.svc_cidr

  existing_vpc_name    = var.existing_vpc_name
  existing_subnet_name = var.existing_subnet_name

  create_hub               = var.restricted_egress
  hub_vpc_google_project   = var.hub_vpc_google_project
  hub_vpc_cidr             = var.hub_vpc_cidr
  is_spoke_vpc_shared      = var.is_spoke_vpc_shared
  workspace_google_project = var.google_project
}

module "private_connectivity" {
  source = "../private-connectivity"
  count  = local.any_private_link ? 1 : 0

  prefix        = var.prefix
  suffix        = random_string.suffix.result
  google_region = var.google_region

  spoke_vpc_id             = module.network[0].spoke_vpc_id
  spoke_vpc_self_link      = module.network[0].spoke_vpc_self_link
  spoke_vpc_google_project = local.spoke_project
  spoke_vpc_cidr           = var.spoke_vpc_cidr

  hub_vpc_id             = var.restricted_egress ? module.network[0].hub_vpc_id : null
  hub_vpc_self_link      = var.restricted_egress ? module.network[0].hub_vpc_self_link : null
  hub_vpc_google_project = var.hub_vpc_google_project
  hub_subnet_name        = var.restricted_egress ? module.network[0].hub_subnet_name : null
  hub_vpc_cidr           = var.hub_vpc_cidr

  enable_frontend = var.private_link_frontend
  enable_backend  = var.private_link_backend
  restrict_egress = var.restricted_egress
  psc_subnet_cidr = var.psc_subnet_cidr

  hive_metastore_ip = var.hive_metastore_ip
}

module "account" {
  source = "../account"

  prefix                = var.prefix
  suffix                = random_string.suffix.result
  workspace_name        = var.workspace_name
  databricks_account_id = var.databricks_account_id
  google_project        = var.google_project
  google_region         = var.google_region
  vpc_source            = var.vpc_source

  spoke_vpc_name           = local.databricks_managed ? null : module.network[0].spoke_vpc_name
  spoke_subnet_name        = local.databricks_managed ? null : module.network[0].spoke_subnet_name
  spoke_vpc_google_project = local.spoke_project
  hub_vpc_google_project   = var.hub_vpc_google_project

  frontend_psc_fr_id     = local.any_private_link ? module.private_connectivity[0].frontend_psc_fr_id : null
  backend_psc_fr_id      = local.any_private_link ? module.private_connectivity[0].backend_psc_fr_id : null
  hub_frontend_psc_fr_id = local.any_private_link ? module.private_connectivity[0].hub_frontend_psc_fr_id : null

  enable_frontend     = var.private_link_frontend
  enable_backend      = var.private_link_backend
  private_access_only = var.private_access_only

  nat_dependency = local.databricks_managed ? null : module.network[0].nat_id
}

module "dns" {
  source = "../dns"
  count  = var.restricted_egress ? 1 : 0

  prefix        = var.prefix
  google_region = var.google_region

  hub_vpc_id             = module.network[0].hub_vpc_id
  hub_vpc_self_link      = module.network[0].hub_vpc_self_link
  hub_vpc_google_project = var.hub_vpc_google_project

  spoke_vpc_id             = module.network[0].spoke_vpc_id
  spoke_vpc_self_link      = module.network[0].spoke_vpc_self_link
  spoke_vpc_google_project = local.spoke_project

  workspace_url = module.account.workspace_url

  frontend_psc_ip_spoke = module.private_connectivity[0].frontend_psc_ip_spoke
  frontend_psc_ip_hub   = module.private_connectivity[0].frontend_psc_ip_hub
  backend_psc_ip_spoke  = module.private_connectivity[0].backend_psc_ip_spoke
}
```

- [ ] **Step 22: Validate the composer module**

```bash
cd modules/gcp/databricks-workspace && terraform init -backend=false && terraform validate
```

Expected: `Success! The configuration is valid.`

Also validate each fixture (4 positive + 4 negative):

```bash
for d in tests/basic tests/byovpc tests/existing-vpc tests/psc-isolated; do
  cd modules/gcp/databricks-workspace/$d && terraform init -backend=false && terraform validate && cd -
done
```

Each should print `Success!`.

The 4 negative fixtures don't need validation here — they're for plan-time precondition failures and we haven't changed precondition logic.

- [ ] **Step 23: Commit**

```bash
git add modules/gcp/network/ modules/gcp/account/ modules/gcp/dns/ modules/gcp/databricks-workspace/
git commit -m "$(cat <<'EOF'
refactor(gcp): split module files by concern

Reorganizes network, account, dns, and databricks-workspace modules
so each .tf file has one clear responsibility. No resource attributes
change; only file boundaries.

- network/main.tf -> vpc.tf, subnets.tf, nat.tf, peering.tf,
  shared-vpc.tf, data.tf, locals.tf
- account/main.tf -> workspace.tf, networks.tf, locals.tf
- dns/hub.tf: workspace_dns_id local extracted to dns/locals.tf
- databricks-workspace/main.tf -> main.tf (module blocks only),
  locals.tf, preconditions.tf, random.tf

Co-authored-by: Isaac
EOF
)"
```

---

## Task 2: Rename forwarding-rule outputs and account inputs

**Goal:** Fix the `*_psc_fr_id` misnomer. These are forwarding-rule **names**, not IDs. Rename outputs in `private-connectivity`, inputs in `account`, and the wiring in the composer — all in one commit so no intermediate state is broken.

**Files:**
- Modify: `modules/gcp/private-connectivity/outputs.tf`
- Modify: `modules/gcp/account/variables.tf`
- Modify: `modules/gcp/account/locals.tf`
- Modify: `modules/gcp/account/networks.tf`
- Modify: `modules/gcp/account/vpc-endpoints.tf`
- Modify: `modules/gcp/account/outputs.tf`
- Modify: `modules/gcp/databricks-workspace/main.tf`
- Modify: `modules/gcp/account/tests/psc-with-pas/main.tf`

- [ ] **Step 1: Rename outputs in `modules/gcp/private-connectivity/outputs.tf`**

Replace the three `*_psc_fr_id` outputs. Use the Edit tool with these exact replacements:

Old (lines 6-19):
```hcl
output "frontend_psc_fr_id" {
  value       = var.enable_frontend ? google_compute_forwarding_rule.frontend_fr_spoke[0].name : null
  description = "Name of the frontend PSC forwarding rule (null when enable_frontend=false)"
}

output "backend_psc_fr_id" {
  value       = var.enable_backend ? google_compute_forwarding_rule.backend_fr[0].name : null
  description = "Name of the backend (SCC) PSC forwarding rule (null when enable_backend=false)"
}

output "hub_frontend_psc_fr_id" {
  value       = local.hub_present && var.enable_frontend ? google_compute_forwarding_rule.frontend_fr_hub[0].name : null
  description = "Name of the hub-side frontend PSC forwarding rule (null when no hub or no frontend)"
}
```

New:
```hcl
output "frontend_forwarding_rule_name" {
  value       = var.enable_frontend ? google_compute_forwarding_rule.frontend_fr_spoke[0].name : null
  description = "Name of the spoke-side frontend PSC forwarding rule (null when enable_frontend=false)"
}

output "backend_forwarding_rule_name" {
  value       = var.enable_backend ? google_compute_forwarding_rule.backend_fr[0].name : null
  description = "Name of the backend (SCC) PSC forwarding rule (null when enable_backend=false)"
}

output "hub_frontend_forwarding_rule_name" {
  value       = local.hub_present && var.enable_frontend ? google_compute_forwarding_rule.frontend_fr_hub[0].name : null
  description = "Name of the hub-side frontend PSC forwarding rule (null when no hub or no frontend)"
}
```

- [ ] **Step 2: Rename inputs in `modules/gcp/account/variables.tf`**

Use Edit to rename the three variables. Old:

```hcl
# Forwarding-rule names from private-connectivity module (gate vpc_endpoint creation)
variable "frontend_psc_fr_id" {
  type    = string
  default = null
}

variable "backend_psc_fr_id" {
  type    = string
  default = null
}

variable "hub_frontend_psc_fr_id" {
  type    = string
  default = null
}
```

New:

```hcl
# Forwarding-rule names from private-connectivity module (gate vpc_endpoint creation)
variable "frontend_forwarding_rule_name" {
  type    = string
  default = null
}

variable "backend_forwarding_rule_name" {
  type    = string
  default = null
}

variable "hub_frontend_forwarding_rule_name" {
  type    = string
  default = null
}
```

- [ ] **Step 3: Update references in `modules/gcp/account/locals.tf`**

Old line:
```hcl
  emit_vpc_endpoints = var.frontend_psc_fr_id != null && var.backend_psc_fr_id != null
```

New:
```hcl
  emit_vpc_endpoints = var.frontend_forwarding_rule_name != null && var.backend_forwarding_rule_name != null
```

- [ ] **Step 4: Update references in `modules/gcp/account/vpc-endpoints.tf`**

The three `databricks_mws_vpc_endpoint` resources each reference one of the renamed variables. Use Edit with `replace_all=true` to replace `var.frontend_psc_fr_id` → `var.frontend_forwarding_rule_name`. Then do the same for `var.backend_psc_fr_id` → `var.backend_forwarding_rule_name` and `var.hub_frontend_psc_fr_id` → `var.hub_frontend_forwarding_rule_name`.

- [ ] **Step 5: Update references in `modules/gcp/account/outputs.tf`**

Three outputs reference these variables in their conditional. Same rename treatment:
- `var.frontend_psc_fr_id` → `var.frontend_forwarding_rule_name`
- `var.backend_psc_fr_id` → `var.backend_forwarding_rule_name`
- `var.hub_frontend_psc_fr_id` → `var.hub_frontend_forwarding_rule_name`

- [ ] **Step 6: Update composer wiring in `modules/gcp/databricks-workspace/main.tf`**

In the `module "account" { ... }` block, rename the three input arguments:

Old (within `module "account"`):
```hcl
  frontend_psc_fr_id     = local.any_private_link ? module.private_connectivity[0].frontend_psc_fr_id : null
  backend_psc_fr_id      = local.any_private_link ? module.private_connectivity[0].backend_psc_fr_id : null
  hub_frontend_psc_fr_id = local.any_private_link ? module.private_connectivity[0].hub_frontend_psc_fr_id : null
```

New:
```hcl
  frontend_forwarding_rule_name     = local.any_private_link ? module.private_connectivity[0].frontend_forwarding_rule_name : null
  backend_forwarding_rule_name      = local.any_private_link ? module.private_connectivity[0].backend_forwarding_rule_name : null
  hub_frontend_forwarding_rule_name = local.any_private_link ? module.private_connectivity[0].hub_frontend_forwarding_rule_name : null
```

- [ ] **Step 7: Update the test fixture `modules/gcp/account/tests/psc-with-pas/main.tf`**

The fixture passes `frontend_psc_fr_id`, `backend_psc_fr_id`, `hub_frontend_psc_fr_id`. Rename to match:

Old:
```hcl
  frontend_psc_fr_id     = "fixture-psc-ws-ep-abc123"
  backend_psc_fr_id      = "fixture-psc-scc-ep-abc123"
  hub_frontend_psc_fr_id = "fixture-hub-psc-ws-ep-abc123"
```

New:
```hcl
  frontend_forwarding_rule_name     = "fixture-psc-ws-ep-abc123"
  backend_forwarding_rule_name      = "fixture-psc-scc-ep-abc123"
  hub_frontend_forwarding_rule_name = "fixture-hub-psc-ws-ep-abc123"
```

- [ ] **Step 8: Validate the affected modules**

```bash
for m in private-connectivity account databricks-workspace; do
  cd modules/gcp/$m && terraform init -backend=false && terraform validate && cd -
done
```

Each should print `Success!`.

Also validate the account fixture that uses the renamed inputs:

```bash
cd modules/gcp/account/tests/psc-with-pas && terraform init -backend=false && terraform validate
```

Expected: `Success!`.

Also validate the composer's psc-isolated fixture:

```bash
cd modules/gcp/databricks-workspace/tests/psc-isolated && terraform init -backend=false && terraform validate
```

Expected: `Success!`.

- [ ] **Step 9: Commit**

```bash
git add modules/gcp/private-connectivity/ modules/gcp/account/ modules/gcp/databricks-workspace/
git commit -m "$(cat <<'EOF'
refactor(gcp): rename *_psc_fr_id to *_forwarding_rule_name

These outputs/inputs hold the GCP forwarding-rule name (an attribute
named `.name`, not `.id`). Renaming for accuracy:

- private-connectivity outputs: frontend_psc_fr_id -> frontend_forwarding_rule_name,
  backend_psc_fr_id -> backend_forwarding_rule_name,
  hub_frontend_psc_fr_id -> hub_frontend_forwarding_rule_name
- account inputs renamed to match
- composer wiring updated; psc-with-pas fixture updated

Co-authored-by: Isaac
EOF
)"
```

---

## Task 3: Expand and rename composer outputs

**Goal:** Drop redundant `vpc_id`, add 14 new outputs, switch `try(module.network[0].*)` to explicit `local.databricks_managed ?` ternaries. Also add the missing `private_access_settings_id` output on the `account` module.

**Files:**
- Modify: `modules/gcp/account/outputs.tf`
- Rewrite: `modules/gcp/databricks-workspace/outputs.tf`
- Modify: `examples/gcp-byovpc/outputs.tf` (replace `vpc_id` reference with `spoke_vpc_id`)
- Modify: `examples/gcp-with-psc-exfiltration-protection/outputs.tf` (same)

- [ ] **Step 1: Add `private_access_settings_id` output to `modules/gcp/account/outputs.tf`**

Append (after the existing `transit_endpoint_id` output):

```hcl

output "private_access_settings_id" {
  value       = local.emit_pas ? databricks_mws_private_access_settings.this[0].private_access_settings_id : null
  description = "databricks_mws_private_access_settings ID (null when private_access_only=false)"
}
```

- [ ] **Step 2: Validate the account module**

```bash
cd modules/gcp/account && terraform init -backend=false && terraform validate
```

Expected: `Success!`.

- [ ] **Step 3: Rewrite `modules/gcp/databricks-workspace/outputs.tf`**

Replace entire file with:

```hcl
# === Workspace ===========================================================
output "workspace_id" {
  value       = module.account.workspace_id
  description = "Databricks workspace ID"
}

output "workspace_url" {
  value       = module.account.workspace_url
  description = "Databricks workspace URL (https://<id>.<random>.gcp.databricks.com)"
}

output "network_id" {
  value       = module.account.network_id
  description = "databricks_mws_networks ID (null when vpc_source=databricks_managed)"
}

output "private_access_settings_id" {
  value       = module.account.private_access_settings_id
  description = "databricks_mws_private_access_settings ID (null when private_access_only=false)"
}

# === mws_vpc_endpoint IDs (Databricks-side PSC registration) ============
output "frontend_endpoint_id" {
  value       = module.account.frontend_endpoint_id
  description = "Frontend mws_vpc_endpoint ID (null when private_link_frontend=false)"
}

output "backend_endpoint_id" {
  value       = module.account.backend_endpoint_id
  description = "Backend (SCC) mws_vpc_endpoint ID (null when private_link_backend=false)"
}

output "transit_endpoint_id" {
  value       = module.account.transit_endpoint_id
  description = "Hub-side mws_vpc_endpoint ID (null when no hub or no frontend PSC)"
}

# === Network =============================================================
output "spoke_vpc_id" {
  value       = local.databricks_managed ? null : module.network[0].spoke_vpc_id
  description = "Spoke VPC ID (null when vpc_source=databricks_managed)"
}

output "spoke_vpc_self_link" {
  value       = local.databricks_managed ? null : module.network[0].spoke_vpc_self_link
  description = "Spoke VPC self-link (null when vpc_source=databricks_managed)"
}

output "spoke_subnet_id" {
  value       = local.databricks_managed ? null : module.network[0].spoke_subnet_id
  description = "Spoke subnet ID (null when vpc_source=databricks_managed)"
}

output "spoke_subnet_self_link" {
  value       = local.databricks_managed ? null : module.network[0].spoke_subnet_self_link
  description = "Spoke subnet self-link (null when vpc_source=databricks_managed)"
}

output "hub_vpc_id" {
  value       = var.restricted_egress ? module.network[0].hub_vpc_id : null
  description = "Hub VPC ID (null when restricted_egress=false)"
}

output "hub_vpc_self_link" {
  value       = var.restricted_egress ? module.network[0].hub_vpc_self_link : null
  description = "Hub VPC self-link (null when restricted_egress=false)"
}

output "nat_id" {
  value       = local.create_vpc ? module.network[0].nat_id : null
  description = "Cloud NAT ID (null when vpc_source != create)"
}

# === Private connectivity ===============================================
output "frontend_psc_ip_spoke" {
  value       = local.any_private_link ? module.private_connectivity[0].frontend_psc_ip_spoke : null
  description = "IP address of the spoke-side frontend PSC endpoint (null when no PSC)"
}

output "backend_psc_ip_spoke" {
  value       = local.any_private_link ? module.private_connectivity[0].backend_psc_ip_spoke : null
  description = "IP address of the spoke-side backend PSC endpoint (null when no PSC)"
}

output "frontend_psc_ip_hub" {
  value       = var.restricted_egress ? module.private_connectivity[0].frontend_psc_ip_hub : null
  description = "IP address of the hub-side frontend PSC endpoint (null when restricted_egress=false)"
}

# === Identifiers ========================================================
output "suffix" {
  value       = random_string.suffix.result
  description = "Random suffix used in resource names (useful when wiring downstream modules)"
}

output "google_region" {
  value       = var.google_region
  description = "Region the workspace was deployed to (echo of input; convenient for downstream modules)"
}
```

- [ ] **Step 4: Validate the composer module**

```bash
cd modules/gcp/databricks-workspace && terraform init -backend=false && terraform validate
```

Expected: `Success!`.

Also validate all 4 positive fixtures:

```bash
for d in tests/basic tests/byovpc tests/existing-vpc tests/psc-isolated; do
  cd modules/gcp/databricks-workspace/$d && terraform init -backend=false && terraform validate && cd -
done
```

Each should print `Success!`.

- [ ] **Step 5: Update `examples/gcp-byovpc/outputs.tf`**

Current file references `module.workspace.vpc_id`. Replace with `module.workspace.spoke_vpc_id`. Use Edit:

Old:
```hcl
output "vpc_id" {
  value       = module.workspace.vpc_id
  description = "ID of the spoke VPC created by the module"
}
```

New:
```hcl
output "vpc_id" {
  value       = module.workspace.spoke_vpc_id
  description = "ID of the spoke VPC created by the module"
}
```

(The example's output name `vpc_id` stays — only the composer's removed `vpc_id` is the breaking change; consumers update their reference.)

- [ ] **Step 6: Update `examples/gcp-with-psc-exfiltration-protection/outputs.tf`**

Same treatment if there's a `module.workspace.vpc_id` reference. Inspect first:

```bash
grep -n "vpc_id" examples/gcp-with-psc-exfiltration-protection/outputs.tf
```

If a reference exists, replace `module.workspace.vpc_id` with `module.workspace.spoke_vpc_id` in the same way.

- [ ] **Step 7: Validate the two examples**

```bash
cd examples/gcp-byovpc && terraform init -backend=false && terraform validate && cd -
cd examples/gcp-with-psc-exfiltration-protection && terraform init -backend=false && terraform validate && cd -
```

Each should print `Success!`.

- [ ] **Step 8: Commit**

```bash
git add modules/gcp/account/outputs.tf modules/gcp/databricks-workspace/outputs.tf examples/gcp-byovpc/outputs.tf examples/gcp-with-psc-exfiltration-protection/outputs.tf
git commit -m "$(cat <<'EOF'
feat(gcp/databricks-workspace): expand and rename composer outputs

- Drop redundant vpc_id (was an alias of spoke_vpc_id)
- Add 14 outputs: private_access_settings_id, frontend/backend/transit
  _endpoint_id, spoke_vpc_self_link, spoke_subnet_id/self_link,
  hub_vpc_self_link, nat_id, frontend/backend/_psc_ip_spoke,
  frontend_psc_ip_hub, google_region
- Replace try(module.network[0].*) with explicit local.databricks_managed
  / var.restricted_egress ternaries (same behavior, intent visible)
- Add private_access_settings_id output on the account module
- Update gcp-byovpc and gcp-with-psc examples to consume spoke_vpc_id
  instead of the removed vpc_id

Co-authored-by: Isaac
EOF
)"
```

---

## Task 4: Add descriptions to all module variables

**Goal:** Ensure every variable in every module has a `description`. Currently: network 17/17, private-connectivity 2/17, account 1/18, dns 0/12, composer 1/23, plus service-account and unity-catalog to check.

**Files:**
- Modify: `modules/gcp/private-connectivity/variables.tf`
- Modify: `modules/gcp/account/variables.tf`
- Modify: `modules/gcp/dns/variables.tf`
- Modify: `modules/gcp/databricks-workspace/variables.tf`
- Modify: `modules/gcp/service-account/variables.tf` (only if any lack descriptions)
- Modify: `modules/gcp/unity-catalog/variables.tf` (only if any lack descriptions)

- [ ] **Step 1: Rewrite `modules/gcp/private-connectivity/variables.tf`**

Replace entire file with:

```hcl
variable "prefix" {
  type        = string
  description = "Prefix used to name generated resources"
}

variable "suffix" {
  type        = string
  description = "Random suffix appended to resource names for uniqueness (passed by the composer)"
}

variable "google_region" {
  type        = string
  description = "GCP region for PSC and firewall resources (must be one of the regions in the regional PSC service-attachment maps)"
}

# Spoke network refs
variable "spoke_vpc_id" {
  type        = string
  description = "ID of the spoke VPC (output from the network module)"
}

variable "spoke_vpc_self_link" {
  type        = string
  description = "Self-link of the spoke VPC (used as the network reference for firewall rules)"
}

variable "spoke_vpc_google_project" {
  type        = string
  description = "GCP project that hosts the spoke VPC"
}

variable "spoke_vpc_cidr" {
  type        = string
  description = "CIDR of the spoke VPC address space (used as source_ranges for the hub ingress firewall)"
}

# Hub network refs (nullable when no hub)
variable "hub_vpc_id" {
  type        = string
  default     = null
  description = "ID of the hub VPC (null when no hub is created)"
}

variable "hub_vpc_self_link" {
  type        = string
  default     = null
  description = "Self-link of the hub VPC (null when no hub is created)"
}

variable "hub_vpc_google_project" {
  type        = string
  default     = null
  description = "GCP project that hosts the hub VPC (null when no hub is created)"
}

variable "hub_subnet_name" {
  type        = string
  default     = null
  description = "Name of the hub subnet (used as the subnetwork reference for the hub-side PSC address)"
}

variable "hub_vpc_cidr" {
  type        = string
  default     = null
  description = "CIDR of the hub VPC address space (reserved for future use)"
}

# Feature flags
variable "enable_frontend" {
  type        = bool
  default     = false
  description = "Create the frontend (workspace UI/API) PSC endpoint on the spoke and, if hub exists, the hub side"
}

variable "enable_backend" {
  type        = bool
  default     = false
  description = "Create the backend (SCC, data plane) PSC endpoint on the spoke"
}

variable "restrict_egress" {
  type        = bool
  default     = false
  description = "Create the egress firewall stack: deny-egress, allow Google APIs, allow control plane, allow managed Hive (conditional), hub ingress"
}

# PSC subnet CIDR
variable "psc_subnet_cidr" {
  type        = string
  description = "CIDR for the dedicated PSC subnet in the spoke VPC"
}

variable "hive_metastore_ip" {
  type        = string
  default     = null
  description = "Regional Hive metastore IP used by the managed-hive allow rule. Looked up via internal map when null; firewall rule is skipped if the lookup also yields empty"
}
```

- [ ] **Step 2: Validate private-connectivity**

```bash
cd modules/gcp/private-connectivity && terraform init -backend=false && terraform validate
```

Expected: `Success!`.

- [ ] **Step 3: Rewrite `modules/gcp/account/variables.tf`**

(Note: variable renames from Task 2 are assumed in place — `*_forwarding_rule_name`.)

Replace entire file with:

```hcl
variable "prefix" {
  type        = string
  description = "Prefix used to name generated resources"
}

variable "suffix" {
  type        = string
  description = "Random suffix appended to resource names for uniqueness (passed by the composer)"
}

variable "workspace_name" {
  type        = string
  default     = null
  description = "Optional workspace name override. Defaults to \"${prefix}-ws-${suffix}\" when null"
}

variable "databricks_account_id" {
  type        = string
  description = "Databricks account ID (GUID) where this workspace will be registered"
}

variable "google_project" {
  type        = string
  description = "GCP project ID hosting the workspace data plane"
}

variable "google_region" {
  type        = string
  description = "GCP region where the workspace will be deployed"
}

variable "vpc_source" {
  type        = string
  description = "One of: databricks_managed (no mws_networks), create (we built the VPC), existing (data-source lookup)"
  validation {
    condition     = contains(["databricks_managed", "create", "existing"], var.vpc_source)
    error_message = "vpc_source must be one of: databricks_managed, create, existing."
  }
}

variable "spoke_vpc_name" {
  type        = string
  default     = null
  description = "Name of the spoke VPC used in databricks_mws_networks.gcp_network_info.vpc_id (null when vpc_source=databricks_managed)"
}

variable "spoke_subnet_name" {
  type        = string
  default     = null
  description = "Name of the spoke subnet used in databricks_mws_networks.gcp_network_info.subnet_id (null when vpc_source=databricks_managed)"
}

variable "spoke_vpc_google_project" {
  type        = string
  default     = null
  description = "GCP project hosting the spoke VPC (used in databricks_mws_networks.gcp_network_info.network_project_id)"
}

variable "hub_vpc_google_project" {
  type        = string
  default     = null
  description = "GCP project hosting the hub VPC (used for the transit databricks_mws_vpc_endpoint when restricted_egress is enabled)"
}

# Forwarding-rule names from private-connectivity module (gate vpc_endpoint creation)
variable "frontend_forwarding_rule_name" {
  type        = string
  default     = null
  description = "Name of the frontend PSC forwarding rule from private-connectivity; gates frontend mws_vpc_endpoint creation"
}

variable "backend_forwarding_rule_name" {
  type        = string
  default     = null
  description = "Name of the backend (SCC) PSC forwarding rule from private-connectivity; gates backend mws_vpc_endpoint creation"
}

variable "hub_frontend_forwarding_rule_name" {
  type        = string
  default     = null
  description = "Name of the hub-side frontend PSC forwarding rule from private-connectivity; gates transit mws_vpc_endpoint creation"
}

variable "enable_frontend" {
  type        = bool
  default     = false
  description = "Create the frontend mws_vpc_endpoint (and, if hub_frontend_forwarding_rule_name is set, the transit endpoint)"
}

variable "enable_backend" {
  type        = bool
  default     = false
  description = "Create the backend (SCC) mws_vpc_endpoint"
}

variable "private_access_only" {
  type        = bool
  default     = false
  description = "Create databricks_mws_private_access_settings with public_access_enabled=false and attach it to the workspace"
}

variable "nat_dependency" {
  type        = any
  default     = null
  description = "Opaque value (typically the Cloud NAT ID) used as depends_on for the workspace to ensure NAT readiness before workspace creation"
}
```

- [ ] **Step 4: Validate account**

```bash
cd modules/gcp/account && terraform init -backend=false && terraform validate
```

Expected: `Success!`.

- [ ] **Step 5: Rewrite `modules/gcp/dns/variables.tf`**

Replace entire file with:

```hcl
variable "prefix" {
  type        = string
  description = "Prefix used to name generated DNS managed zones"
}

variable "google_region" {
  type        = string
  description = "GCP region (used in the spoke tunnel DNS record name)"
}

# Hub
variable "hub_vpc_id" {
  type        = string
  description = "ID of the hub VPC (DNS zones with this VPC's visibility)"
}

variable "hub_vpc_self_link" {
  type        = string
  description = "Self-link of the hub VPC"
}

variable "hub_vpc_google_project" {
  type        = string
  description = "GCP project hosting the hub VPC (used for the hub DNS zones)"
}

# Spoke
variable "spoke_vpc_id" {
  type        = string
  description = "ID of the spoke VPC (DNS zone with this VPC's visibility)"
}

variable "spoke_vpc_self_link" {
  type        = string
  description = "Self-link of the spoke VPC"
}

variable "spoke_vpc_google_project" {
  type        = string
  description = "GCP project hosting the spoke VPC (used for the spoke DNS zone)"
}

# Workspace
variable "workspace_url" {
  type        = string
  description = "Workspace URL from databricks_mws_workspaces; used to extract the workspace DNS ID via regex"
}

# PSC IPs
variable "frontend_psc_ip_spoke" {
  type        = string
  description = "Spoke-side frontend PSC endpoint IP (used in the spoke gcp.databricks.com A records)"
}

variable "frontend_psc_ip_hub" {
  type        = string
  default     = null
  description = "Hub-side frontend PSC endpoint IP (used in the hub gcp.databricks.com A records)"
}

variable "backend_psc_ip_spoke" {
  type        = string
  description = "Spoke-side backend (SCC) PSC endpoint IP (used in the spoke tunnel.<region>.gcp.databricks.com A record)"
}
```

- [ ] **Step 6: Validate dns**

```bash
cd modules/gcp/dns && terraform init -backend=false && terraform validate
```

Expected: `Success!`.

- [ ] **Step 7: Rewrite `modules/gcp/databricks-workspace/variables.tf`**

Replace entire file with:

```hcl
# === Identity ============================================================
variable "prefix" {
  type        = string
  description = "Prefix used to name generated resources (e.g. \"acme\" produces \"acme-spoke-vpc-<suffix>\")"
}

variable "databricks_account_id" {
  type        = string
  description = "Databricks account ID (GUID) where this workspace will be registered"
}

variable "google_project" {
  type        = string
  description = "GCP project ID hosting the workspace data plane"
}

variable "google_region" {
  type        = string
  description = "GCP region where the workspace will be deployed. When any private_link_* flag or restricted_egress is true, the region must be supported by Databricks PSC (see preconditions.tf)"
}

variable "workspace_name" {
  type        = string
  default     = null
  description = "Optional workspace name override. Defaults to \"${prefix}-ws-${suffix}\" when null"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Map of tags. Currently not propagated to child resources; reserved for future use"
}

# === VPC source ==========================================================
variable "vpc_source" {
  type        = string
  default     = "databricks_managed"
  description = "Where the workspace VPC comes from. One of: databricks_managed (no networking module called), create (Terraform creates VPC + subnet + NAT), existing (data-source lookup)"
  validation {
    condition     = contains(["databricks_managed", "create", "existing"], var.vpc_source)
    error_message = "vpc_source must be one of: databricks_managed, create, existing."
  }
}

# When vpc_source = "create"
variable "spoke_vpc_cidr" {
  type        = string
  default     = null
  description = "CIDR of the spoke VPC address space (e.g. 10.0.0.0/16). Required when vpc_source=create; ignored otherwise"
}

variable "subnet_cidr" {
  type        = string
  default     = null
  description = "CIDR of the spoke subnet primary range (e.g. 10.0.0.0/22). Required when vpc_source=create"
}

variable "pod_cidr" {
  type        = string
  default     = null
  description = "Optional CIDR for the GKE pods secondary range. Adds a secondary_ip_range to the spoke subnet when set"
}

variable "svc_cidr" {
  type        = string
  default     = null
  description = "Optional CIDR for the GKE services secondary range. Adds a secondary_ip_range to the spoke subnet when set"
}

# When vpc_source = "existing"
variable "existing_vpc_name" {
  type        = string
  default     = null
  description = "Name of the pre-existing VPC to use. Required when vpc_source=existing"
}

variable "existing_subnet_name" {
  type        = string
  default     = null
  description = "Name of the pre-existing subnet to use (must be in google_region). Required when vpc_source=existing"
}

# === Connectivity feature flags ==========================================
variable "private_link_frontend" {
  type        = bool
  default     = false
  description = "Create the frontend (workspace UI/API) PSC endpoint and a frontend databricks_mws_vpc_endpoint"
}

variable "private_link_backend" {
  type        = bool
  default     = false
  description = "Create the backend (SCC, data plane) PSC endpoint and a backend databricks_mws_vpc_endpoint"
}

variable "private_access_only" {
  type        = bool
  default     = false
  description = "Create databricks_mws_private_access_settings with public_access_enabled=false. Workspace becomes reachable only through PSC endpoints"
}

variable "restricted_egress" {
  type        = bool
  default     = false
  description = "Create hub VPC + bidirectional peering + deny-egress firewall + private DNS zones. Requires vpc_source=create and at least one private_link_* flag"
}

# === Required when restricted_egress = true ==============================
variable "hub_vpc_google_project" {
  type        = string
  default     = null
  description = "GCP project hosting the hub VPC. Required when restricted_egress=true"
}

variable "spoke_vpc_google_project" {
  type        = string
  default     = null
  description = "GCP project hosting the spoke VPC. Defaults to google_project when null"
}

variable "is_spoke_vpc_shared" {
  type        = bool
  default     = false
  description = "If true, bind the spoke VPC project as a Shared-VPC host and the workspace project as a service project. Only takes effect when restricted_egress=true and the two projects differ"
}

variable "hub_vpc_cidr" {
  type        = string
  default     = null
  description = "CIDR of the hub subnet (e.g. 10.1.0.0/24). Required when restricted_egress=true"
}

variable "psc_subnet_cidr" {
  type        = string
  default     = null
  description = "CIDR of the dedicated PSC subnet in the spoke VPC (e.g. 10.0.255.0/28). Required when restricted_egress=true or any private_link_* flag is true"
}

variable "hive_metastore_ip" {
  type        = string
  default     = null
  description = "Regional Hive metastore IP used by the managed-hive allow rule. When null, the regional default is looked up internally; if no default exists for the region, the rule is skipped"
}
```

- [ ] **Step 8: Validate composer**

```bash
cd modules/gcp/databricks-workspace && terraform init -backend=false && terraform validate
```

Expected: `Success!`.

- [ ] **Step 9: Inspect and update `modules/gcp/service-account/variables.tf` if needed**

```bash
grep -c "description" modules/gcp/service-account/variables.tf
grep -c "^variable" modules/gcp/service-account/variables.tf
```

If the description count equals the variable count, skip. Otherwise add descriptions. The current file:

```bash
cat modules/gcp/service-account/variables.tf
```

If any variable lacks a description, add one based on its name (e.g. `google_project` → "GCP project ID where the service account will be created", `prefix` → "Prefix used to name the service account and custom role", `delegate_from` → "Identities (user/group/serviceAccount) that may impersonate the created service account").

- [ ] **Step 10: Inspect and update `modules/gcp/unity-catalog/variables.tf` if needed**

Same pattern as Step 9. Inspect:

```bash
grep -c "description" modules/gcp/unity-catalog/variables.tf
grep -c "^variable" modules/gcp/unity-catalog/variables.tf
```

If gaps exist, add descriptions.

- [ ] **Step 11: Validate everything again to be safe**

```bash
for m in private-connectivity account dns databricks-workspace service-account unity-catalog; do
  cd modules/gcp/$m && terraform init -backend=false && terraform validate && cd -
done
```

All should print `Success!`.

- [ ] **Step 12: Commit**

```bash
git add modules/gcp/private-connectivity/variables.tf modules/gcp/account/variables.tf modules/gcp/dns/variables.tf modules/gcp/databricks-workspace/variables.tf modules/gcp/service-account/variables.tf modules/gcp/unity-catalog/variables.tf
git commit -m "$(cat <<'EOF'
docs(gcp): add descriptions to all module variables

Adds the description attribute to every variable across
private-connectivity, account, dns, databricks-workspace (composer),
and any gaps in service-account / unity-catalog. ~70 descriptions
total. Surfaces in generated terraform-docs READMEs and IDE hovers.

Co-authored-by: Isaac
EOF
)"
```

---

## Task 5: Add region validations

**Goal:** Validate `google_region` against the supported-region list at two layers: as a variable validation in `private-connectivity` (always enforced), and as a precondition in the composer (only when PSC or restricted_egress is requested).

**Files:**
- Modify: `modules/gcp/private-connectivity/variables.tf`
- Modify: `modules/gcp/databricks-workspace/preconditions.tf`

- [ ] **Step 1: Add validation block to `private-connectivity/variables.tf`**

The `google_region` variable was rewritten in Task 4. Edit it to add a `validation` block:

Old (after Task 4):
```hcl
variable "google_region" {
  type        = string
  description = "GCP region for PSC and firewall resources (must be one of the regions in the regional PSC service-attachment maps)"
}
```

New:
```hcl
variable "google_region" {
  type        = string
  description = "GCP region for PSC and firewall resources (must be one of the regions in the regional PSC service-attachment maps)"
  validation {
    condition = contains([
      "asia-northeast1", "asia-south1", "asia-southeast1", "australia-southeast1",
      "europe-west1", "europe-west2", "europe-west3", "northamerica-northeast1",
      "southamerica-east1", "us-central1", "us-east1", "us-east4", "us-west1", "us-west4"
    ], var.google_region)
    error_message = "google_region must be one of the regions in the regional PSC service-attachment maps. See locals.tf in modules/gcp/private-connectivity."
  }
}
```

- [ ] **Step 2: Validate private-connectivity passes (with a region that satisfies the new rule)**

```bash
cd modules/gcp/private-connectivity && terraform init -backend=false && terraform validate
cd modules/gcp/private-connectivity/tests/full-isolated && terraform validate
cd modules/gcp/private-connectivity/tests/no-egress && terraform validate
```

All three should print `Success!`. (Both fixtures use `us-central1`, which is in the list.)

- [ ] **Step 3: Add region precondition to composer `preconditions.tf`**

Insert a 7th `precondition { ... }` block inside the existing `null_resource.preconditions.lifecycle` block. Use Edit on `modules/gcp/databricks-workspace/preconditions.tf` to add this BEFORE the closing `}` of the `lifecycle` block:

```hcl
    precondition {
      condition = (
        !local.any_private_link && !var.restricted_egress
        ) || contains([
        "asia-northeast1", "asia-south1", "asia-southeast1", "australia-southeast1",
        "europe-west1", "europe-west2", "europe-west3", "northamerica-northeast1",
        "southamerica-east1", "us-central1", "us-east1", "us-east4", "us-west1", "us-west4"
      ], var.google_region)
      error_message = "google_region must be a region supported by Databricks PSC when any private_link_* flag or restricted_egress is true."
    }
```

- [ ] **Step 4: Validate the composer**

```bash
cd modules/gcp/databricks-workspace && terraform init -backend=false && terraform validate
```

Expected: `Success!`.

Validate all positive fixtures still work (they all use us-central1):

```bash
for d in tests/basic tests/byovpc tests/existing-vpc tests/psc-isolated; do
  cd modules/gcp/databricks-workspace/$d && terraform init -backend=false && terraform validate && cd -
done
```

Each: `Success!`.

- [ ] **Step 5: Spot-check that the existing 4 negative fixtures still fail plan as expected**

The new precondition shouldn't change the behavior of the existing negatives (they fail other rules first). Verify:

```bash
for d in tests/negative-restricted-egress-managed tests/negative-restricted-egress-missing-hub tests/negative-existing-missing-name tests/negative-managed-with-psc; do
  cd modules/gcp/databricks-workspace/$d
  terraform init -backend=false 2>/dev/null
  if terraform plan -refresh=false 2>&1 | grep -q "Error:"; then
    echo "OK: $d still fails"
  else
    echo "FAIL: $d unexpectedly passed plan"
  fi
  cd -
done
```

All 4 should print "OK: ... still fails".

- [ ] **Step 6: Commit**

```bash
git add modules/gcp/private-connectivity/variables.tf modules/gcp/databricks-workspace/preconditions.tf
git commit -m "$(cat <<'EOF'
feat(gcp): add region validations on private-connectivity and composer

private-connectivity now validates google_region against the 14
regions present in the regional PSC service-attachment maps. The
composer adds the same validation as a precondition, but only when
any private_link_* flag or restricted_egress is true. Bad regions
now fail plan with a clear message instead of a confusing
map-lookup error at apply time.

Co-authored-by: Isaac
EOF
)"
```

---

## Task 6: Standardize provider/versions placement

**Goal:** Every module uses a single `versions.tf` containing only the terraform block; no provider configuration blocks live inside modules. Every example uses `versions.tf` + `providers.tf` split.

**Files:**
- Modify: `modules/gcp/service-account/init.tf` (split: remove `provider "google" {}`, move `terraform {}` block to `versions.tf`)
- Create: `modules/gcp/service-account/versions.tf`
- Delete: `modules/gcp/service-account/init.tf`
- Rename: `modules/gcp/unity-catalog/terraform.tf` → `modules/gcp/unity-catalog/versions.tf` (git mv)
- For each of `examples/gcp-basic`, `examples/gcp-byovpc`, `examples/gcp-existing-vpc`, `examples/gcp-sa-provisioning`: split `init.tf` into `versions.tf` (terraform block) + `providers.tf` (provider blocks)
- Rename `examples/gcp-with-psc-exfiltration-protection/terraform.tf` → `examples/gcp-with-psc-exfiltration-protection/versions.tf`

- [ ] **Step 1: Inspect the current service-account init.tf**

```bash
cat modules/gcp/service-account/init.tf
```

The file should contain a `terraform { required_providers { ... } }` block and a `provider "google" {}` block.

- [ ] **Step 2: Create `modules/gcp/service-account/versions.tf`**

Write only the `terraform` block (copy from init.tf). For example:

```hcl
terraform {
  required_version = ">= 1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
  }
}
```

(Adjust to match exactly what's in `init.tf` minus the `provider "google" {}` block. If the current `init.tf` lacks `required_version`, add `required_version = ">= 1.5"`.)

- [ ] **Step 3: Delete `modules/gcp/service-account/init.tf`**

```bash
git rm modules/gcp/service-account/init.tf
```

- [ ] **Step 4: Validate service-account**

```bash
cd modules/gcp/service-account && terraform init -backend=false && terraform validate
```

Expected: `Success!`.

- [ ] **Step 5: Rename `modules/gcp/unity-catalog/terraform.tf` to `versions.tf`**

```bash
git mv modules/gcp/unity-catalog/terraform.tf modules/gcp/unity-catalog/versions.tf
```

- [ ] **Step 6: Validate unity-catalog**

```bash
cd modules/gcp/unity-catalog && terraform init -backend=false && terraform validate
```

Expected: `Success!`.

- [ ] **Step 7: Split `examples/gcp-basic/init.tf`**

Inspect:

```bash
cat examples/gcp-basic/init.tf
```

The file has both `terraform { required_providers { ... } }` and `provider "google" {}` + `provider "databricks" {}` blocks.

Create `examples/gcp-basic/versions.tf` with just the `terraform` block:

```hcl
terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
    google = {
      source = "hashicorp/google"
    }
  }
}
```

Create `examples/gcp-basic/providers.tf` with the provider blocks:

```hcl
provider "google" {
  project = var.google_project
  region  = var.google_region
  zone    = var.google_zone
}

provider "databricks" {
  host                   = "https://accounts.gcp.databricks.com"
  google_service_account = var.databricks_google_service_account
  account_id             = var.databricks_account_id
}
```

Delete `init.tf`:

```bash
git rm examples/gcp-basic/init.tf
```

Validate:

```bash
cd examples/gcp-basic && terraform init -backend=false && terraform validate
```

Expected: `Success!`.

- [ ] **Step 8: Repeat the split for `examples/gcp-byovpc/`**

Same operation as Step 7. Inspect first, then split `init.tf` into `versions.tf` + `providers.tf`, then delete `init.tf`. Validate.

- [ ] **Step 9: Repeat the split for `examples/gcp-existing-vpc/`**

Same operation. Inspect, split, delete, validate.

- [ ] **Step 10: Repeat the split for `examples/gcp-sa-provisioning/`**

Same operation. Note: this example's `init.tf` may not declare the databricks provider (since the example only provisions GCP resources, no Databricks API calls). Inspect carefully and split accordingly. The `provider "google" {}` block that lived inside the module (deleted in Step 3) should be reflected here — make sure the example's `provider "google"` is configured with the user's `google_project`, `google_region`, and `google_zone`.

- [ ] **Step 11: Rename `examples/gcp-with-psc-exfiltration-protection/terraform.tf` to `versions.tf`**

```bash
git mv examples/gcp-with-psc-exfiltration-protection/terraform.tf examples/gcp-with-psc-exfiltration-protection/versions.tf
```

Validate:

```bash
cd examples/gcp-with-psc-exfiltration-protection && terraform init -backend=false && terraform validate
```

Expected: `Success!`.

(`providers.tf` already exists in this example; no other changes needed.)

- [ ] **Step 12: Final validate of all 5 examples**

```bash
for d in examples/gcp-basic examples/gcp-byovpc examples/gcp-existing-vpc examples/gcp-sa-provisioning examples/gcp-with-psc-exfiltration-protection; do
  cd $d && terraform init -backend=false && terraform validate && cd -
done
```

All 5: `Success!`.

- [ ] **Step 13: Commit**

```bash
git add modules/gcp/service-account/ modules/gcp/unity-catalog/ examples/gcp-basic/ examples/gcp-byovpc/ examples/gcp-existing-vpc/ examples/gcp-sa-provisioning/ examples/gcp-with-psc-exfiltration-protection/
git commit -m "$(cat <<'EOF'
refactor(gcp): standardize provider/versions placement

Modules now contain only the terraform { required_providers } block in
a file named versions.tf. No provider configuration blocks inside
modules (the service-account module previously carried provider
"google" {}; moved to its example).

Examples standardize on versions.tf (terraform block) + providers.tf
(provider blocks):
- gcp-basic, gcp-byovpc, gcp-existing-vpc, gcp-sa-provisioning: init.tf
  split into versions.tf + providers.tf
- gcp-with-psc-exfiltration-protection: terraform.tf renamed to
  versions.tf (providers.tf already existed)
- unity-catalog module: terraform.tf renamed to versions.tf

Co-authored-by: Isaac
EOF
)"
```

---

## Task 7: Add `## Usage` sections to module READMEs

**Goal:** Each module README has a `## Usage` block above the terraform-docs marker showing a minimal call example. Mirrors terraform-google-modules convention.

**Files:**
- Modify: `modules/gcp/databricks-workspace/README.md`
- Modify: `modules/gcp/network/README.md`
- Modify: `modules/gcp/private-connectivity/README.md`
- Modify: `modules/gcp/account/README.md`
- Modify: `modules/gcp/dns/README.md`
- Modify: `modules/gcp/service-account/README.md`
- Modify: `modules/gcp/unity-catalog/README.md`

The pattern: take the existing README (which is `# title\n\n<one-line description>\n\n<!-- BEGIN_TF_DOCS -->\n<!-- END_TF_DOCS -->`), and insert a `## Usage` section between the description and the BEGIN_TF_DOCS marker.

- [ ] **Step 1: Update `modules/gcp/databricks-workspace/README.md`**

Read the current README, then use Edit to insert this block immediately before `<!-- BEGIN_TF_DOCS -->`:

```markdown
## Usage

```hcl
module "workspace" {
  source = "github.com/databricks/terraform-databricks-examples//modules/gcp/databricks-workspace"

  prefix                = "acme"
  databricks_account_id = var.databricks_account_id
  google_project        = "my-workspace-project"
  google_region         = "us-central1"

  vpc_source = "databricks_managed"   # or "create" / "existing"
}
```

See `examples/gcp-basic`, `examples/gcp-byovpc`, `examples/gcp-existing-vpc`, and `examples/gcp-with-psc-exfiltration-protection` for the four supported scenarios.

```

- [ ] **Step 2: Update `modules/gcp/network/README.md`**

Same pattern. Insert before BEGIN_TF_DOCS:

```markdown
## Usage

Typically called by `modules/gcp/databricks-workspace` (the composer). Direct consumption is supported but unusual; you'll need to wire the outputs yourself.

```hcl
module "network" {
  source = "github.com/databricks/terraform-databricks-examples//modules/gcp/network"

  prefix                   = "acme"
  suffix                   = "abc123"
  google_region            = "us-central1"
  vpc_source               = "create"
  spoke_vpc_google_project = "my-project"
  spoke_vpc_cidr           = "10.0.0.0/16"
  subnet_cidr              = "10.0.0.0/22"
}
```

```

- [ ] **Step 3: Update `modules/gcp/private-connectivity/README.md`**

```markdown
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

```

- [ ] **Step 4: Update `modules/gcp/account/README.md`**

```markdown
## Usage

Typically called by `modules/gcp/databricks-workspace` (the composer). Direct consumption is supported but unusual.

```hcl
module "account" {
  source = "github.com/databricks/terraform-databricks-examples//modules/gcp/account"

  prefix                = "acme"
  suffix                = "abc123"
  databricks_account_id = var.databricks_account_id
  google_project        = "my-workspace-project"
  google_region         = "us-central1"
  vpc_source            = "databricks_managed"
}
```

```

- [ ] **Step 5: Update `modules/gcp/dns/README.md`**

```markdown
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

  workspace_url = module.account.workspace_url

  frontend_psc_ip_spoke = module.private_connectivity.frontend_psc_ip_spoke
  frontend_psc_ip_hub   = module.private_connectivity.frontend_psc_ip_hub
  backend_psc_ip_spoke  = module.private_connectivity.backend_psc_ip_spoke
}
```

```

- [ ] **Step 6: Update `modules/gcp/service-account/README.md`**

```markdown
## Usage

Run once per GCP project to provision the service account Databricks uses to deploy workspaces.

```hcl
module "service_account" {
  source = "github.com/databricks/terraform-databricks-examples//modules/gcp/service-account"

  google_project = "my-project"
  prefix         = "acme"
  delegate_from  = ["user:alice@example.com"]
}
```

The consumer must also configure `provider "google" {}` (project + region/zone) — this module no longer carries its own provider configuration.

```

- [ ] **Step 7: Update `modules/gcp/unity-catalog/README.md`**

```markdown
## Usage

Called after `modules/gcp/databricks-workspace` to create a metastore, GCS bucket, storage credential, external location, and default catalog.

```hcl
module "unity_catalog" {
  source = "github.com/databricks/terraform-databricks-examples//modules/gcp/unity-catalog"

  providers = {
    databricks           = databricks
    databricks.workspace = databricks.workspace
  }

  databricks_workspace_id  = module.workspace.workspace_id
  databricks_workspace_url = module.workspace.workspace_url
  google_project           = "my-workspace-project"
  google_region            = "us-central1"
  prefix                   = "acme"
  metastore_name           = "main-metastore"
  catalog_name             = "main"
}
```

The consumer must declare a `databricks.workspace` provider alias pointing at the workspace URL.

```

- [ ] **Step 8: Validate that README changes didn't break anything**

The READMEs are doc-only; no terraform impact. Skip explicit validate. Confirm git status looks correct:

```bash
git status --short
```

Expected: 7 modified README.md files under modules/gcp/.

- [ ] **Step 9: Commit**

```bash
git add modules/gcp/databricks-workspace/README.md modules/gcp/network/README.md modules/gcp/private-connectivity/README.md modules/gcp/account/README.md modules/gcp/dns/README.md modules/gcp/service-account/README.md modules/gcp/unity-catalog/README.md
git commit -m "$(cat <<'EOF'
docs(gcp): add Usage sections to module READMEs

Each module README now has a Usage block above the terraform-docs
marker showing a minimal calling example. Mirrors the convention
used by terraform-google-modules and the HashiCorp registry.

Submodule READMEs note "Typically called by modules/gcp/databricks-
workspace (the composer); consume directly only if you have a reason
to". The composer README points to the four scenario examples.

Co-authored-by: Isaac
EOF
)"
```

---

## Task 8: Regenerate terraform-docs READMEs

**Goal:** Refresh the auto-generated `<!-- BEGIN_TF_DOCS -->`...`<!-- END_TF_DOCS -->` blocks across all 7 GCP modules to reflect every change made in Tasks 1-7 (descriptions, renames, new outputs, the additional precondition resource is irrelevant to docs).

**Files:**
- Modify: every `modules/gcp/*/README.md` (terraform-docs regen)

- [ ] **Step 1: Regenerate docs for each module**

Run from inside each module directory to avoid touching unrelated module READMEs:

```bash
for m in databricks-workspace network private-connectivity account dns service-account unity-catalog; do
  cd modules/gcp/$m && make docs && cd -
done
```

Each invocation should print `README.md updated successfully`.

- [ ] **Step 2: Verify only the 7 GCP modules' READMEs changed**

```bash
git status --short
```

Expected: 7 modified `modules/gcp/*/README.md` files and nothing else. If any other files appear (especially under `modules/adb-*/` or `modules/aws-*/`), STOP — those should NOT be touched. Reset those specific files with `git checkout -- <path>` before continuing.

- [ ] **Step 3: Spot-check that the renamed outputs / new outputs / new descriptions all appear in the regenerated tables**

```bash
grep "frontend_forwarding_rule_name" modules/gcp/private-connectivity/README.md modules/gcp/account/README.md
grep "private_access_settings_id" modules/gcp/databricks-workspace/README.md modules/gcp/account/README.md
grep -c "google_region" modules/gcp/databricks-workspace/README.md
```

Each should return a line; the count should be at least 2 (input table + maybe outputs table mention).

- [ ] **Step 4: Commit**

```bash
git add modules/gcp/databricks-workspace/README.md modules/gcp/network/README.md modules/gcp/private-connectivity/README.md modules/gcp/account/README.md modules/gcp/dns/README.md modules/gcp/service-account/README.md modules/gcp/unity-catalog/README.md
git commit -m "$(cat <<'EOF'
docs(gcp): regenerate terraform-docs READMEs after refactor

Final regeneration sweep after the best-practices refactor pass.
Reflects: variable descriptions (~70), output renames (*_psc_fr_id ->
*_forwarding_rule_name), expanded composer outputs (14 new), and the
provider/versions reorganization.

Co-authored-by: Isaac
EOF
)"
```

---

## Self-Review

(Performed after writing the plan; issues found fixed inline.)

**1. Spec coverage:**

| Spec requirement | Task |
|------------------|------|
| Variable descriptions (Goal 1) | Task 4 |
| File organization by concern (Goal 2) | Task 1 |
| `versions.tf` everywhere, no provider configs in modules (Goal 3) | Task 6 |
| Same file shape across examples (Goal 4) | Task 6 |
| Composer outputs cover everything + explicit ternaries (Goal 5) | Task 3 |
| Output/variable name accuracy (Goal 6) | Tasks 2 and 3 |
| `google_region` validation (Goal 7) | Task 5 |
| `## Usage` blocks in every module README (Goal 8) | Task 7 |
| terraform-docs regen | Task 8 |

Coverage is complete.

**2. Placeholder scan:** Searched for "TBD", "TODO", "implement later", "appropriate", "as needed". None found.

**3. Type consistency:**
- `frontend_forwarding_rule_name` / `backend_forwarding_rule_name` / `hub_frontend_forwarding_rule_name` used consistently across Task 2 (renames), Task 4 (descriptions referencing the new names), and Task 7 (Usage block doesn't reference these directly).
- `private_access_settings_id` introduced as account output in Task 3 Step 1, then consumed by the composer output in Task 3 Step 3.
- `local.databricks_managed`, `local.create_vpc`, `local.use_existing_vpc`, `local.any_private_link`, `local.spoke_project` defined in Task 1 Step 18 (composer locals.tf), referenced in Task 3 Step 3 (outputs) and Task 5 Step 3 (precondition). Matches.
- The 14-region list appears in two places (Task 5 Step 1 in private-connectivity, Task 5 Step 3 in composer). Lists are identical.

**4. Spec requirements with no task:** None.

---

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-05-26-gcp-best-practices-refactor.md`.

Two execution options:

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration.

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints.

Which approach?
