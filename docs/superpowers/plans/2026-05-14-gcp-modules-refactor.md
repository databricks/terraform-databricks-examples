# GCP Modules Refactor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace three duplicated GCP workspace modules with one composer (`modules/gcp/databricks-workspace`) that orchestrates five focused submodules (`network`, `private-connectivity`, `account`, `dns`, plus relocated `service-account` and `unity-catalog`). Migrate existing GCP examples one at a time onto the composer and add a new "existing VPC" example.

**Architecture:** Composer reads orthogonal feature flags (`vpc_source`, `private_link_frontend`, `private_link_backend`, `private_access_only`, `restricted_egress`) and conditionally instantiates submodules via `count`. Dependency graph is linear: `network → private-connectivity → account → dns`. All `databricks_mws_*` resources live in `account`; all GCP-side PSC resources live in `private-connectivity`; DNS is split out because it depends on `account.workspace_url`.

**Tech Stack:** Terraform >= 1.5, `hashicorp/google` provider, `databricks/databricks` provider, `terraform-docs`, `pre-commit`. No new tooling.

**Spec reference:** `docs/superpowers/specs/2026-05-14-gcp-modules-refactor-design.md`

**Branch:** `feature/gcp-modules-refactor` (already created; spec committed as `2bfd9bd`).

---

## File Structure

This plan creates the following new tree (incremental — each task creates one slice):

```
docs/superpowers/                        # already exists
  ├── specs/2026-05-14-gcp-modules-refactor-design.md   # already committed
  └── plans/2026-05-14-gcp-modules-refactor.md           # this file

modules/gcp/
  ├── Makefile                           # Task 1 — recursive docs/test_docs
  ├── databricks-workspace/              # Task 14–17 — composer
  │   ├── main.tf
  │   ├── variables.tf
  │   ├── outputs.tf
  │   ├── versions.tf
  │   ├── README.md                      # terraform-docs generates
  │   ├── Makefile
  │   └── tests/                         # plan-time validation fixtures
  │       ├── basic/main.tf
  │       ├── byovpc/main.tf
  │       ├── existing-vpc/main.tf
  │       ├── psc-isolated/main.tf
  │       └── negative-*/main.tf         # expect plan failure
  ├── network/                           # Task 3–5
  │   ├── main.tf
  │   ├── variables.tf
  │   ├── outputs.tf
  │   ├── versions.tf
  │   ├── README.md
  │   ├── Makefile
  │   └── tests/
  │       ├── create/main.tf
  │       ├── existing/main.tf
  │       └── create-with-hub/main.tf
  ├── private-connectivity/              # Task 6–8
  │   ├── psc.tf
  │   ├── firewall.tf
  │   ├── variables.tf
  │   ├── outputs.tf
  │   ├── versions.tf
  │   ├── locals.tf                      # regional PSC + hive metastore maps
  │   ├── README.md
  │   ├── Makefile
  │   └── tests/
  │       ├── frontend-only/main.tf
  │       ├── full-isolated/main.tf
  │       └── no-egress/main.tf
  ├── account/                           # Task 9–13
  │   ├── main.tf                        # mws_networks + mws_workspaces
  │   ├── vpc-endpoints.tf               # mws_vpc_endpoint
  │   ├── pas.tf                         # mws_private_access_settings
  │   ├── variables.tf
  │   ├── outputs.tf
  │   ├── versions.tf
  │   ├── README.md
  │   ├── Makefile
  │   └── tests/
  │       ├── databricks-managed/main.tf
  │       ├── byovpc/main.tf
  │       └── psc-with-pas/main.tf
  ├── dns/                               # Task 18–19
  │   ├── hub.tf
  │   ├── spoke.tf
  │   ├── variables.tf
  │   ├── outputs.tf
  │   ├── versions.tf
  │   ├── README.md
  │   ├── Makefile
  │   └── tests/hub-and-spoke/main.tf
  ├── service-account/                   # Task 20 (git mv from modules/gcp-sa-provisioning)
  └── unity-catalog/                     # Task 21 (git mv from modules/gcp-unity-catalog)

modules/gcp-sa-provisioning/             # Task 20 — replaced with deprecation README
  └── README.md

modules/gcp-unity-catalog/               # Task 21 — replaced with deprecation README
  └── README.md

examples/gcp-basic/                      # Task 24 — migrated
examples/gcp-byovpc/                     # Task 25 — migrated
examples/gcp-with-psc-exfiltration-protection/   # Task 26 — migrated
examples/gcp-existing-vpc/               # Task 27 — NEW
examples/gcp-sa-provisioning/            # Task 28 — repoint to relocated module

# Deletions (Task 29 onward, PR 6)
modules/gcp-workspace-basic/             # DELETE
modules/gcp-workspace-byovpc/            # DELETE
modules/gcp-with-psc-exfiltration-protection/   # DELETE
modules/gcp-sa-provisioning/             # DELETE (stub)
modules/gcp-unity-catalog/               # DELETE (stub)
examples/gcp-sa-provisionning/           # DELETE (typo dir)
examples/gcp-test-modules/               # DELETE (state-only)
```

**Testing approach for each module task:** Each submodule gets `tests/<scenario>/main.tf` fixtures that call the module with mock vars. The "test" is `terraform init -backend=false && terraform validate && terraform plan -refresh=false` against the fixture. We don't apply — we verify the configuration is valid and the planned resource graph matches expectations.

**Conventions to follow** (observed in existing repo):
- `versions.tf` declares required_providers and required terraform version
- `Makefile` per module has `docs:` and `test_docs:` targets calling `terraform-docs -c ../../.terraform-docs.yml .` (note: for nested `modules/gcp/<name>/`, the path becomes `../../../.terraform-docs.yml`)
- README sections between `<!-- BEGIN_TF_DOCS -->` and `<!-- END_TF_DOCS -->` are managed by `terraform-docs`
- Resource names use `${var.prefix}-<role>-${random_string.suffix.result}` pattern
- `random_string.suffix` is declared **only in the composer**, then passed to submodules via `suffix` input

---

## PR 1 — Foundation

This PR adds all new modules under `modules/gcp/` and relocates `service-account` + `unity-catalog`. No example is touched. The deliverable at the end of PR 1 is: a complete new module tree that passes `terraform validate` for every fixture, with no example consuming it yet.

### Task 1: Repo scaffolding — `modules/gcp/Makefile` and `tests/` convention

**Files:**
- Create: `modules/gcp/Makefile`

- [ ] **Step 1: Inspect existing Makefile pattern**

Read `modules/Makefile` and `modules/gcp-workspace-basic/Makefile` to confirm conventions.

Run: `cat modules/Makefile modules/gcp-workspace-basic/Makefile`

Expected: top-level discovers projects via `*/README.md`, each module Makefile invokes `terraform-docs -c ../../.terraform-docs.yml .`.

- [ ] **Step 2: Create `modules/gcp/Makefile`**

Write:

```makefile
PROJECTS := $(dir $(wildcard */README.md))

docs: $(PROJECTS)

$(PROJECTS):
	$(MAKE) -C $@ docs

.PHONY: $(PROJECTS) docs
```

- [ ] **Step 3: Update top-level `modules/Makefile` to recurse into `gcp/`**

Read current `modules/Makefile`. It only iterates `*/README.md`. Since `modules/gcp/` has no README of its own, we add an explicit recursion.

Edit `modules/Makefile`:

```makefile
PROJECTS := $(dir $(wildcard */README.md))

docs: $(PROJECTS) gcp-recursive

$(PROJECTS):
	$(MAKE) -C $@ docs

gcp-recursive:
	$(MAKE) -C gcp docs

.PHONY: $(PROJECTS) docs gcp-recursive
```

- [ ] **Step 4: Commit**

```bash
git add modules/gcp/Makefile modules/Makefile
git commit -m "$(cat <<'EOF'
build: add Makefile recursion for modules/gcp/ submodules

Adds modules/gcp/Makefile mirroring the modules/ pattern (discover
sub-projects via */README.md) and updates modules/Makefile to recurse
into the gcp/ subdir for terraform-docs generation.

Co-authored-by: Isaac
EOF
)"
```

---

### Task 2: `modules/gcp/network` — skeleton + variables + versions

**Files:**
- Create: `modules/gcp/network/variables.tf`
- Create: `modules/gcp/network/main.tf`
- Create: `modules/gcp/network/outputs.tf`
- Create: `modules/gcp/network/versions.tf`
- Create: `modules/gcp/network/Makefile`
- Create: `modules/gcp/network/README.md` (placeholder, terraform-docs fills it)

- [ ] **Step 1: Write `versions.tf`**

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

- [ ] **Step 2: Write `variables.tf`**

```hcl
variable "prefix" {
  type        = string
  description = "Prefix for generated resource names"
}

variable "suffix" {
  type        = string
  description = "Random suffix passed by the composer for uniqueness"
}

variable "google_region" {
  type        = string
  description = "GCP region for all network resources"
}

variable "vpc_source" {
  type        = string
  description = "Either 'create' (Terraform creates a VPC) or 'existing' (data-source lookup)"
  validation {
    condition     = contains(["create", "existing"], var.vpc_source)
    error_message = "vpc_source must be 'create' or 'existing'."
  }
}

# Spoke project always required
variable "spoke_vpc_google_project" {
  type        = string
  description = "GCP project hosting the spoke VPC"
}

# === Used when vpc_source = "create" ====================================
variable "spoke_vpc_cidr" {
  type        = string
  default     = null
  description = "CIDR for the spoke subnet primary range (required when vpc_source=create)"
}

variable "subnet_cidr" {
  type        = string
  default     = null
  description = "CIDR for the spoke subnet (required when vpc_source=create)"
}

variable "subnet_name" {
  type        = string
  default     = null
  description = "Override for spoke subnet name (default: \"${prefix}-subnet-${suffix}\")"
}

variable "pod_cidr" {
  type        = string
  default     = null
  description = "GKE secondary range for pods (optional)"
}

variable "svc_cidr" {
  type        = string
  default     = null
  description = "GKE secondary range for services (optional)"
}

# === Used when vpc_source = "existing" ==================================
variable "existing_vpc_name" {
  type        = string
  default     = null
  description = "Name of pre-existing VPC (required when vpc_source=existing)"
}

variable "existing_subnet_name" {
  type        = string
  default     = null
  description = "Name of pre-existing subnet (required when vpc_source=existing)"
}

# === Hub configuration (only when create_hub = true) ====================
variable "create_hub" {
  type        = bool
  default     = false
  description = "Create a hub VPC + subnet + peering with the spoke. Composer passes restricted_egress here."
}

variable "hub_vpc_google_project" {
  type        = string
  default     = null
  description = "GCP project hosting the hub VPC (required when create_hub=true)"
}

variable "hub_vpc_cidr" {
  type        = string
  default     = null
  description = "CIDR for the hub subnet (required when create_hub=true)"
}

variable "is_spoke_vpc_shared" {
  type        = bool
  default     = false
  description = "If true, bind the spoke VPC's project as a Shared-VPC host and the workspace project as a service project"
}

variable "workspace_google_project" {
  type        = string
  default     = null
  description = "Workspace project (used for Shared-VPC service binding)"
}
```

- [ ] **Step 3: Write empty `main.tf` and `outputs.tf`**

`main.tf`:

```hcl
# Resources added in Tasks 3, 4, 5
```

`outputs.tf`:

```hcl
output "spoke_vpc_id" {
  value       = null
  description = "ID of the spoke VPC"
}

output "spoke_vpc_name" {
  value       = null
  description = "Name of the spoke VPC"
}

output "spoke_vpc_self_link" {
  value       = null
  description = "Self-link of the spoke VPC"
}

output "spoke_subnet_id" {
  value       = null
  description = "ID of the spoke subnet"
}

output "spoke_subnet_name" {
  value       = null
  description = "Name of the spoke subnet"
}

output "spoke_subnet_self_link" {
  value       = null
  description = "Self-link of the spoke subnet"
}

output "hub_vpc_id" {
  value       = null
  description = "ID of the hub VPC (null when create_hub=false)"
}

output "hub_vpc_name" {
  value       = null
  description = "Name of the hub VPC (null when create_hub=false)"
}

output "hub_vpc_self_link" {
  value       = null
  description = "Self-link of the hub VPC (null when create_hub=false)"
}

output "hub_subnet_name" {
  value       = null
  description = "Name of the hub subnet (null when create_hub=false)"
}

output "nat_id" {
  value       = null
  description = "ID of the Cloud NAT (null when vpc_source=existing)"
}
```

(Outputs are wired to real resources in Tasks 3–5.)

- [ ] **Step 4: Write `Makefile`**

```makefile
.PHONY: docs test_docs

docs:
	terraform-docs -c ../../../.terraform-docs.yml .

test_docs:
	terraform-docs -c ../../../.terraform-docs.yml --output-check .
```

- [ ] **Step 5: Write `README.md` placeholder**

```markdown
# modules/gcp/network

VPC, subnet, router, NAT, peering, and Shared-VPC binding for the Databricks GCP composer.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
```

- [ ] **Step 6: Validate**

Run:
```bash
cd modules/gcp/network && terraform init -backend=false && terraform validate
```

Expected: `Success! The configuration is valid.`

- [ ] **Step 7: Commit**

```bash
git add modules/gcp/network/
git commit -m "$(cat <<'EOF'
feat(gcp/network): scaffold module with variables and outputs

Adds modules/gcp/network with variable declarations, empty outputs,
versions.tf, Makefile, and README placeholder. Resources to be added
in subsequent tasks.

Co-authored-by: Isaac
EOF
)"
```

---

### Task 3: `modules/gcp/network` — create-vpc path + fixture

**Files:**
- Modify: `modules/gcp/network/main.tf`
- Modify: `modules/gcp/network/outputs.tf`
- Create: `modules/gcp/network/tests/create/main.tf`

- [ ] **Step 1: Write the test fixture `tests/create/main.tf`**

```hcl
terraform {
  required_version = ">= 1.5"
}

provider "google" {
  project = "fixture-project"
  region  = "us-central1"
}

module "network" {
  source = "../.."

  prefix                   = "fixture"
  suffix                   = "abc123"
  google_region            = "us-central1"
  vpc_source               = "create"
  spoke_vpc_google_project = "fixture-project"
  spoke_vpc_cidr           = "10.0.0.0/16"
  subnet_cidr              = "10.0.0.0/22"
}
```

- [ ] **Step 2: Run the fixture, expect plan to show no resources (no implementation yet)**

```bash
cd modules/gcp/network/tests/create
terraform init -backend=false
terraform validate
terraform plan -refresh=false
```

Expected: validate passes, plan shows `No changes. Your infrastructure matches the configuration.` (no resources defined in module yet).

- [ ] **Step 3: Implement the create-vpc path in `modules/gcp/network/main.tf`**

```hcl
locals {
  create_vpc = var.vpc_source == "create"
  use_existing_vpc = var.vpc_source == "existing"

  subnet_name = coalesce(var.subnet_name, "${var.prefix}-subnet-${var.suffix}")
}

# === Spoke VPC (created) ================================================
resource "google_compute_network" "spoke_vpc" {
  count = local.create_vpc ? 1 : 0

  name                    = "${var.prefix}-spoke-vpc-${var.suffix}"
  project                 = var.spoke_vpc_google_project
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
}

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

- [ ] **Step 4: Wire outputs in `outputs.tf`**

Replace the `null` placeholders:

```hcl
output "spoke_vpc_id" {
  value       = local.create_vpc ? google_compute_network.spoke_vpc[0].id : null
  description = "ID of the spoke VPC"
}

output "spoke_vpc_name" {
  value       = local.create_vpc ? google_compute_network.spoke_vpc[0].name : null
  description = "Name of the spoke VPC"
}

output "spoke_vpc_self_link" {
  value       = local.create_vpc ? google_compute_network.spoke_vpc[0].self_link : null
  description = "Self-link of the spoke VPC"
}

output "spoke_subnet_id" {
  value       = local.create_vpc ? google_compute_subnetwork.spoke_subnet[0].id : null
  description = "ID of the spoke subnet"
}

output "spoke_subnet_name" {
  value       = local.create_vpc ? google_compute_subnetwork.spoke_subnet[0].name : null
  description = "Name of the spoke subnet"
}

output "spoke_subnet_self_link" {
  value       = local.create_vpc ? google_compute_subnetwork.spoke_subnet[0].self_link : null
  description = "Self-link of the spoke subnet"
}

output "nat_id" {
  value       = local.create_vpc ? google_compute_router_nat.nat[0].id : null
  description = "ID of the Cloud NAT (null when vpc_source=existing)"
}

# hub_* outputs still null at this point; updated in Task 5.
output "hub_vpc_id"        { value = null  description = "ID of the hub VPC (null when create_hub=false)" }
output "hub_vpc_name"      { value = null  description = "Name of the hub VPC (null when create_hub=false)" }
output "hub_vpc_self_link" { value = null  description = "Self-link of the hub VPC (null when create_hub=false)" }
output "hub_subnet_name"   { value = null  description = "Name of the hub subnet (null when create_hub=false)" }
```

- [ ] **Step 5: Re-run fixture and verify resource count**

```bash
cd modules/gcp/network/tests/create
terraform plan -refresh=false
```

Expected: `Plan: 4 to add, 0 to change, 0 to destroy.` (network + subnet + router + nat).

- [ ] **Step 6: Commit**

```bash
git add modules/gcp/network/
git commit -m "$(cat <<'EOF'
feat(gcp/network): implement create-vpc path

Adds google_compute_network/subnetwork/router/router_nat resources
gated on vpc_source="create". Outputs wired to real resources.
Fixture in tests/create/ asserts 4 resources are planned.

Co-authored-by: Isaac
EOF
)"
```

---

### Task 4: `modules/gcp/network` — existing-vpc path + fixture

**Files:**
- Modify: `modules/gcp/network/main.tf`
- Modify: `modules/gcp/network/outputs.tf`
- Create: `modules/gcp/network/tests/existing/main.tf`

- [ ] **Step 1: Write fixture `tests/existing/main.tf`**

```hcl
terraform {
  required_version = ">= 1.5"
}

provider "google" {
  project = "fixture-project"
  region  = "us-central1"
}

module "network" {
  source = "../.."

  prefix                   = "fixture"
  suffix                   = "abc123"
  google_region            = "us-central1"
  vpc_source               = "existing"
  spoke_vpc_google_project = "fixture-project"
  existing_vpc_name        = "preexisting-vpc"
  existing_subnet_name     = "preexisting-subnet"
}
```

- [ ] **Step 2: Add data sources to `main.tf`**

Append to `modules/gcp/network/main.tf`:

```hcl
# === Spoke VPC (data lookup) ============================================
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

- [ ] **Step 3: Update outputs to merge create and existing paths**

In `outputs.tf` replace the four spoke outputs:

```hcl
output "spoke_vpc_id" {
  value = local.create_vpc ? google_compute_network.spoke_vpc[0].id :
    local.use_existing_vpc ? data.google_compute_network.existing_spoke[0].id : null
  description = "ID of the spoke VPC"
}

output "spoke_vpc_name" {
  value = local.create_vpc ? google_compute_network.spoke_vpc[0].name :
    local.use_existing_vpc ? data.google_compute_network.existing_spoke[0].name : null
  description = "Name of the spoke VPC"
}

output "spoke_vpc_self_link" {
  value = local.create_vpc ? google_compute_network.spoke_vpc[0].self_link :
    local.use_existing_vpc ? data.google_compute_network.existing_spoke[0].self_link : null
  description = "Self-link of the spoke VPC"
}

output "spoke_subnet_id" {
  value = local.create_vpc ? google_compute_subnetwork.spoke_subnet[0].id :
    local.use_existing_vpc ? data.google_compute_subnetwork.existing_spoke_subnet[0].id : null
  description = "ID of the spoke subnet"
}

output "spoke_subnet_name" {
  value = local.create_vpc ? google_compute_subnetwork.spoke_subnet[0].name :
    local.use_existing_vpc ? data.google_compute_subnetwork.existing_spoke_subnet[0].name : null
  description = "Name of the spoke subnet"
}

output "spoke_subnet_self_link" {
  value = local.create_vpc ? google_compute_subnetwork.spoke_subnet[0].self_link :
    local.use_existing_vpc ? data.google_compute_subnetwork.existing_spoke_subnet[0].self_link : null
  description = "Self-link of the spoke subnet"
}
```

- [ ] **Step 4: Run fixture, expect plan with zero resources (data sources only)**

```bash
cd modules/gcp/network/tests/existing
terraform init -backend=false
terraform validate
terraform plan -refresh=false
```

Expected: validate passes; plan shows `No changes` (data sources don't appear as planned resources without applying; we accept this — the test is `validate` passing without errors).

- [ ] **Step 5: Commit**

```bash
git add modules/gcp/network/
git commit -m "$(cat <<'EOF'
feat(gcp/network): implement existing-vpc path

Adds data.google_compute_network and data.google_compute_subnetwork
lookups gated on vpc_source="existing". Spoke outputs now resolve
from either created resources or data sources.

Co-authored-by: Isaac
EOF
)"
```

---

### Task 5: `modules/gcp/network` — hub & peering & shared-VPC + fixture

**Files:**
- Modify: `modules/gcp/network/main.tf`
- Modify: `modules/gcp/network/outputs.tf`
- Create: `modules/gcp/network/tests/create-with-hub/main.tf`

- [ ] **Step 1: Write fixture `tests/create-with-hub/main.tf`**

```hcl
terraform {
  required_version = ">= 1.5"
}

provider "google" {
  project = "fixture-project"
  region  = "us-central1"
}

module "network" {
  source = "../.."

  prefix                   = "fixture"
  suffix                   = "abc123"
  google_region            = "us-central1"
  vpc_source               = "create"
  spoke_vpc_google_project = "fixture-spoke-project"
  spoke_vpc_cidr           = "10.0.0.0/16"
  subnet_cidr              = "10.0.0.0/22"

  create_hub               = true
  hub_vpc_google_project   = "fixture-hub-project"
  hub_vpc_cidr             = "10.1.0.0/24"
  is_spoke_vpc_shared      = true
  workspace_google_project = "fixture-workspace-project"
}
```

- [ ] **Step 2: Append hub + peering + shared-VPC resources to `main.tf`**

```hcl
# === Hub VPC ============================================================
resource "google_compute_network" "hub_vpc" {
  count = var.create_hub ? 1 : 0

  name                    = "${var.prefix}-hub-vpc-${var.suffix}"
  project                 = var.hub_vpc_google_project
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
}

resource "google_compute_subnetwork" "hub_subnet" {
  count = var.create_hub ? 1 : 0

  name                     = "${var.prefix}-hub-subnet-${var.suffix}"
  project                  = var.hub_vpc_google_project
  network                  = google_compute_network.hub_vpc[0].id
  region                   = var.google_region
  ip_cidr_range            = var.hub_vpc_cidr
  private_ip_google_access = true
}

# === Peering ============================================================
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

# === Shared VPC =========================================================
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

- [ ] **Step 3: Wire hub outputs in `outputs.tf`**

```hcl
output "hub_vpc_id" {
  value       = var.create_hub ? google_compute_network.hub_vpc[0].id : null
  description = "ID of the hub VPC (null when create_hub=false)"
}

output "hub_vpc_name" {
  value       = var.create_hub ? google_compute_network.hub_vpc[0].name : null
  description = "Name of the hub VPC (null when create_hub=false)"
}

output "hub_vpc_self_link" {
  value       = var.create_hub ? google_compute_network.hub_vpc[0].self_link : null
  description = "Self-link of the hub VPC (null when create_hub=false)"
}

output "hub_subnet_name" {
  value       = var.create_hub ? google_compute_subnetwork.hub_subnet[0].name : null
  description = "Name of the hub subnet (null when create_hub=false)"
}
```

- [ ] **Step 4: Validate and plan**

```bash
cd modules/gcp/network/tests/create-with-hub
terraform init -backend=false
terraform validate
terraform plan -refresh=false
```

Expected: `Plan: 8 to add, 0 to change, 0 to destroy.` (4 spoke + 2 hub + 2 peering + 2 shared-vpc — wait, 4+2+2+2=10. Let me recount: spoke_vpc, spoke_subnet, router, nat = 4. hub_vpc, hub_subnet = 2. hub_to_spoke peering, spoke_to_hub peering = 2. shared_vpc_host, shared_vpc_service = 2. Total = 10).

Expected: `Plan: 10 to add`.

- [ ] **Step 5: Commit**

```bash
git add modules/gcp/network/
git commit -m "$(cat <<'EOF'
feat(gcp/network): add hub VPC, peering, and Shared-VPC binding

Adds hub VPC + subnet + bidirectional peering with spoke + optional
shared-VPC host/service binding, all gated on create_hub. Composer
passes restricted_egress -> create_hub.

Co-authored-by: Isaac
EOF
)"
```

---

### Task 6: `modules/gcp/private-connectivity` — scaffold + locals (regional maps)

**Files:**
- Create: `modules/gcp/private-connectivity/versions.tf`
- Create: `modules/gcp/private-connectivity/variables.tf`
- Create: `modules/gcp/private-connectivity/locals.tf`
- Create: `modules/gcp/private-connectivity/outputs.tf`
- Create: `modules/gcp/private-connectivity/psc.tf` (empty)
- Create: `modules/gcp/private-connectivity/firewall.tf` (empty)
- Create: `modules/gcp/private-connectivity/Makefile`
- Create: `modules/gcp/private-connectivity/README.md` placeholder

- [ ] **Step 1: `versions.tf`**

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

- [ ] **Step 2: `variables.tf`**

```hcl
variable "prefix"        { type = string }
variable "suffix"        { type = string }
variable "google_region" { type = string }

# Spoke network refs
variable "spoke_vpc_id"             { type = string }
variable "spoke_vpc_self_link"      { type = string }
variable "spoke_vpc_google_project" { type = string }
variable "spoke_vpc_cidr"           { type = string }

# Hub network refs (nullable when no hub)
variable "hub_vpc_id"             { type = string  default = null }
variable "hub_vpc_self_link"      { type = string  default = null }
variable "hub_vpc_google_project" { type = string  default = null }
variable "hub_subnet_name"        { type = string  default = null }
variable "hub_vpc_cidr"           { type = string  default = null }

# Feature flags
variable "enable_frontend" { type = bool  default = false }
variable "enable_backend"  { type = bool  default = false }
variable "restrict_egress" { type = bool  default = false }

# PSC subnet CIDR (always required when this module is invoked because
# the composer only instantiates it when at least one PSC flag is true)
variable "psc_subnet_cidr" {
  type        = string
  description = "CIDR for the dedicated PSC subnet in the spoke VPC"
}

# Optional hive metastore IP override; falls back to regional map
variable "hive_metastore_ip" {
  type        = string
  default     = null
  description = "Regional Hive metastore IP (looked up via internal map if null)"
}
```

- [ ] **Step 3: `locals.tf` — regional PSC service-attachment + hive metastore maps**

Copy the maps verbatim from `modules/gcp-with-psc-exfiltration-protection/main.tf`. The plan reproduces them in full because future region additions will land in one place going forward.

```hcl
locals {
  google_frontend_psc_targets = {
    "asia-northeast1"         = "projects/general-prod-asianortheast1-01/regions/asia-northeast1/serviceAttachments/plproxy-psc-endpoint-all-ports"
    "asia-south1"             = "projects/gen-prod-asias1-01/regions/asia-south1/serviceAttachments/plproxy-psc-endpoint-all-ports"
    "asia-southeast1"         = "projects/general-prod-asiasoutheast1-01/regions/asia-southeast1/serviceAttachments/plproxy-psc-endpoint-all-ports"
    "australia-southeast1"    = "projects/general-prod-ausoutheast1-01/regions/australia-southeast1/serviceAttachments/plproxy-psc-endpoint-all-ports"
    "europe-west1"            = "projects/general-prod-europewest1-01/regions/europe-west1/serviceAttachments/plproxy-psc-endpoint-all-ports"
    "europe-west2"            = "projects/general-prod-europewest2-01/regions/europe-west2/serviceAttachments/plproxy-psc-endpoint-all-ports"
    "europe-west3"            = "projects/general-prod-europewest3-01/regions/europe-west3/serviceAttachments/plproxy-psc-endpoint-all-ports"
    "northamerica-northeast1" = "projects/general-prod-nanortheast1-01/regions/northamerica-northeast1/serviceAttachments/plproxy-psc-endpoint-all-ports"
    "southamerica-east1"      = "projects/gen-prod-saeast1-01/regions/southamerica-east1/serviceAttachments/plproxy-psc-endpoint-all-ports"
    "us-central1"             = "projects/gcp-prod-general/regions/us-central1/serviceAttachments/plproxy-psc-endpoint-all-ports"
    "us-east1"                = "projects/general-prod-useast1-01/regions/us-east1/serviceAttachments/plproxy-psc-endpoint-all-ports"
    "us-east4"                = "projects/general-prod-useast4-01/regions/us-east4/serviceAttachments/plproxy-psc-endpoint-all-ports"
    "us-west1"                = "projects/general-prod-uswest1-01/regions/us-west1/serviceAttachments/plproxy-psc-endpoint-all-ports"
    "us-west4"                = "projects/general-prod-uswest4-01/regions/us-west4/serviceAttachments/plproxy-psc-endpoint-all-ports"
  }

  google_backend_psc_targets = {
    "asia-northeast1"         = "projects/prod-gcp-asia-northeast1/regions/asia-northeast1/serviceAttachments/ngrok-psc-endpoint"
    "asia-south1"             = "projects/prod-gcp-asia-south1/regions/asia-south1/serviceAttachments/ngrok-psc-endpoint"
    "asia-southeast1"         = "projects/prod-gcp-asia-southeast1/regions/asia-southeast1/serviceAttachments/ngrok-psc-endpoint"
    "australia-southeast1"    = "projects/prod-gcp-australia-southeast1/regions/australia-southeast1/serviceAttachments/ngrok-psc-endpoint"
    "europe-west1"            = "projects/prod-gcp-europe-west1/regions/europe-west1/serviceAttachments/ngrok-psc-endpoint"
    "europe-west2"            = "projects/prod-gcp-europe-west2/regions/europe-west2/serviceAttachments/ngrok-psc-endpoint"
    "europe-west3"            = "projects/prod-gcp-europe-west3/regions/europe-west3/serviceAttachments/ngrok-psc-endpoint"
    "northamerica-northeast1" = "projects/prod-gcp-na-northeast1/regions/northamerica-northeast1/serviceAttachments/ngrok-psc-endpoint"
    "southamerica-east1"      = "projects/gen-prod-saeast1-01/regions/southamerica-east1/serviceAttachments/ngrok-psc-endpoint"
    "us-central1"             = "projects/prod-gcp-us-central1/regions/us-central1/serviceAttachments/ngrok-psc-endpoint"
    "us-east1"                = "projects/prod-gcp-us-east1/regions/us-east1/serviceAttachments/ngrok-psc-endpoint"
    "us-east4"                = "projects/prod-gcp-us-east4/regions/us-east4/serviceAttachments/ngrok-psc-endpoint"
    "us-west1"                = "projects/prod-gcp-us-west1/regions/us-west1/serviceAttachments/ngrok-psc-endpoint"
    "us-west4"                = "projects/prod-gcp-us-west4/regions/us-west4/serviceAttachments/ngrok-psc-endpoint"
  }

  # Regional default Hive Metastore IPs per Databricks docs:
  # https://docs.gcp.databricks.com/en/resources/ip-domain-region.html#addresses-for-default-metastore
  # NOTE: keep this list curated. When null, the firewall rule omits the
  # managed-hive allowance (acceptable when customers run their own metastore).
  default_hive_metastore_ips = {
    # Filled in by ops; leave empty initially. Override via var.hive_metastore_ip.
  }

  hive_metastore_ip = coalesce(var.hive_metastore_ip, try(local.default_hive_metastore_ips[var.google_region], ""))

  hub_present = var.hub_vpc_id != null
}
```

- [ ] **Step 4: Empty `psc.tf`, `firewall.tf`, `Makefile`, `README.md`, `outputs.tf`**

`outputs.tf`:

```hcl
output "psc_subnet_self_link"   { value = null  description = "Self-link of the PSC subnet" }
output "frontend_psc_fr_id"     { value = null  description = "Name of the frontend PSC forwarding rule (null when enable_frontend=false)" }
output "backend_psc_fr_id"      { value = null  description = "Name of the backend (SCC) PSC forwarding rule (null when enable_backend=false)" }
output "hub_frontend_psc_fr_id" { value = null  description = "Name of the hub-side frontend PSC forwarding rule (null when no hub or no frontend)" }
output "frontend_psc_ip_spoke"  { value = null  description = "IP address of the spoke-side frontend PSC endpoint" }
output "backend_psc_ip_spoke"   { value = null  description = "IP address of the spoke-side backend PSC endpoint" }
output "frontend_psc_ip_hub"    { value = null  description = "IP address of the hub-side frontend PSC endpoint (null when no hub)" }
```

`psc.tf` and `firewall.tf` are empty for now (filled in next tasks).

`Makefile`:

```makefile
.PHONY: docs test_docs

docs:
	terraform-docs -c ../../../.terraform-docs.yml .

test_docs:
	terraform-docs -c ../../../.terraform-docs.yml --output-check .
```

`README.md`:

```markdown
# modules/gcp/private-connectivity

GCP-side PSC endpoints + restricted-egress firewall for the Databricks GCP composer.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
```

- [ ] **Step 5: Validate**

```bash
cd modules/gcp/private-connectivity && terraform init -backend=false && terraform validate
```

Expected: `Success! The configuration is valid.`

- [ ] **Step 6: Commit**

```bash
git add modules/gcp/private-connectivity/
git commit -m "$(cat <<'EOF'
feat(gcp/private-connectivity): scaffold with regional PSC maps

Adds modules/gcp/private-connectivity with variables, regional PSC
service-attachment + hive metastore maps in locals.tf, empty psc.tf
and firewall.tf, null outputs. Resources added in follow-up tasks.

Co-authored-by: Isaac
EOF
)"
```

---

### Task 7: `modules/gcp/private-connectivity` — PSC subnet + endpoints + fixture

**Files:**
- Modify: `modules/gcp/private-connectivity/psc.tf`
- Modify: `modules/gcp/private-connectivity/outputs.tf`
- Create: `modules/gcp/private-connectivity/tests/full-isolated/main.tf`

- [ ] **Step 1: Write fixture `tests/full-isolated/main.tf`**

```hcl
terraform {
  required_version = ">= 1.5"
}

provider "google" {
  project = "fixture-spoke"
  region  = "us-central1"
}

module "pc" {
  source = "../.."

  prefix        = "fixture"
  suffix        = "abc123"
  google_region = "us-central1"

  spoke_vpc_id             = "projects/fixture-spoke/global/networks/spoke-vpc"
  spoke_vpc_self_link      = "https://www.googleapis.com/compute/v1/projects/fixture-spoke/global/networks/spoke-vpc"
  spoke_vpc_google_project = "fixture-spoke"
  spoke_vpc_cidr           = "10.0.0.0/16"

  hub_vpc_id             = "projects/fixture-hub/global/networks/hub-vpc"
  hub_vpc_self_link      = "https://www.googleapis.com/compute/v1/projects/fixture-hub/global/networks/hub-vpc"
  hub_vpc_google_project = "fixture-hub"
  hub_subnet_name        = "fixture-hub-subnet-abc123"
  hub_vpc_cidr           = "10.1.0.0/24"

  enable_frontend = true
  enable_backend  = true
  restrict_egress = true
  psc_subnet_cidr = "10.0.255.0/28"
}
```

- [ ] **Step 2: Implement `psc.tf`**

```hcl
# === PSC Subnet (spoke) =================================================
resource "google_compute_subnetwork" "psc_subnet" {
  name                     = "${var.prefix}-psc-subnet-${var.suffix}"
  project                  = var.spoke_vpc_google_project
  network                  = var.spoke_vpc_id
  region                   = var.google_region
  ip_cidr_range            = var.psc_subnet_cidr
  private_ip_google_access = true
}

# === Backend (SCC) PSC endpoint — spoke =================================
resource "google_compute_address" "backend_address" {
  count = var.enable_backend ? 1 : 0

  name         = "${var.prefix}-psc-scc-ip-${var.suffix}"
  project      = var.spoke_vpc_google_project
  region       = var.google_region
  subnetwork   = google_compute_subnetwork.psc_subnet.name
  address_type = "INTERNAL"
}

resource "google_compute_forwarding_rule" "backend_fr" {
  count = var.enable_backend ? 1 : 0

  name                  = "${var.prefix}-psc-scc-ep-${var.suffix}"
  project               = var.spoke_vpc_google_project
  region                = var.google_region
  network               = var.spoke_vpc_id
  ip_address            = google_compute_address.backend_address[0].id
  target                = local.google_backend_psc_targets[var.google_region]
  load_balancing_scheme = ""
}

# === Frontend PSC endpoint — spoke ======================================
resource "google_compute_address" "frontend_address_spoke" {
  count = var.enable_frontend ? 1 : 0

  name         = "${var.prefix}-psc-ws-ip-${var.suffix}"
  project      = var.spoke_vpc_google_project
  region       = var.google_region
  subnetwork   = google_compute_subnetwork.psc_subnet.name
  address_type = "INTERNAL"
}

resource "google_compute_forwarding_rule" "frontend_fr_spoke" {
  count = var.enable_frontend ? 1 : 0

  name                  = "${var.prefix}-psc-ws-ep-${var.suffix}"
  project               = var.spoke_vpc_google_project
  region                = var.google_region
  network               = var.spoke_vpc_id
  ip_address            = google_compute_address.frontend_address_spoke[0].id
  target                = local.google_frontend_psc_targets[var.google_region]
  load_balancing_scheme = ""
}

# === Frontend PSC endpoint — hub (transit) ==============================
resource "google_compute_address" "frontend_address_hub" {
  count = local.hub_present && var.enable_frontend ? 1 : 0

  name         = "${var.prefix}-hub-psc-ws-ip-${var.suffix}"
  project      = var.hub_vpc_google_project
  region       = var.google_region
  subnetwork   = var.hub_subnet_name
  address_type = "INTERNAL"
}

resource "google_compute_forwarding_rule" "frontend_fr_hub" {
  count = local.hub_present && var.enable_frontend ? 1 : 0

  name                  = "${var.prefix}-hub-psc-ws-ep-${var.suffix}"
  project               = var.hub_vpc_google_project
  region                = var.google_region
  network               = var.hub_vpc_id
  ip_address            = google_compute_address.frontend_address_hub[0].id
  target                = local.google_frontend_psc_targets[var.google_region]
  load_balancing_scheme = ""
}
```

- [ ] **Step 3: Wire PSC outputs in `outputs.tf`**

```hcl
output "psc_subnet_self_link" {
  value       = google_compute_subnetwork.psc_subnet.self_link
  description = "Self-link of the PSC subnet"
}

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

output "frontend_psc_ip_spoke" {
  value       = var.enable_frontend ? google_compute_address.frontend_address_spoke[0].address : null
  description = "IP address of the spoke-side frontend PSC endpoint"
}

output "backend_psc_ip_spoke" {
  value       = var.enable_backend ? google_compute_address.backend_address[0].address : null
  description = "IP address of the spoke-side backend PSC endpoint"
}

output "frontend_psc_ip_hub" {
  value       = local.hub_present && var.enable_frontend ? google_compute_address.frontend_address_hub[0].address : null
  description = "IP address of the hub-side frontend PSC endpoint (null when no hub)"
}
```

- [ ] **Step 4: Validate fixture**

```bash
cd modules/gcp/private-connectivity/tests/full-isolated
terraform init -backend=false
terraform validate
terraform plan -refresh=false
```

Expected: `Plan: 7 to add` (PSC subnet + 2 addresses + 2 forwarding rules for spoke + 1 address + 1 forwarding rule for hub).

- [ ] **Step 5: Commit**

```bash
git add modules/gcp/private-connectivity/
git commit -m "$(cat <<'EOF'
feat(gcp/private-connectivity): add PSC subnet, addresses, forwarding rules

PSC subnet (spoke); backend (SCC) endpoint gated on enable_backend;
frontend endpoint (spoke) gated on enable_frontend; frontend endpoint
(hub) gated on hub_present AND enable_frontend.

Co-authored-by: Isaac
EOF
)"
```

---

### Task 8: `modules/gcp/private-connectivity` — egress firewall rules + fixture

**Files:**
- Modify: `modules/gcp/private-connectivity/firewall.tf`
- Modify: `modules/gcp/private-connectivity/tests/full-isolated/main.tf` (no change to assertions; the plan resource count grows)
- Create: `modules/gcp/private-connectivity/tests/no-egress/main.tf` (variant with `restrict_egress = false`)

- [ ] **Step 1: Write `firewall.tf`**

```hcl
# Egress firewall stack — only emitted when restrict_egress = true.
# Names follow the existing pattern from modules/gcp-with-psc-exfiltration-protection/firewall-spoke.tf
# and firewall-hub.tf to keep operator familiarity.

# === Spoke deny-egress ==================================================
resource "google_compute_firewall" "spoke_default_deny_egress" {
  count = var.restrict_egress ? 1 : 0

  name    = "${var.prefix}-spoke-${var.suffix}-default-deny-egress"
  project = var.spoke_vpc_google_project
  network = var.spoke_vpc_self_link

  direction          = "EGRESS"
  priority           = 1100
  destination_ranges = ["0.0.0.0/0"]
  source_ranges      = []

  deny {
    protocol = "all"
  }
}

# === Spoke allow Google APIs ============================================
resource "google_compute_firewall" "spoke_allow_google_apis" {
  count = var.restrict_egress ? 1 : 0

  name    = "${var.prefix}-spoke-${var.suffix}-to-google-apis"
  project = var.spoke_vpc_google_project
  network = var.spoke_vpc_self_link

  direction = "EGRESS"
  priority  = 1000
  destination_ranges = [
    "199.36.153.4/30",
    "199.36.153.8/30",
    "34.126.0.0/18"
  ]

  allow {
    protocol = "all"
  }
}

# === Spoke allow Databricks control plane (to PSC IPs) ==================
resource "google_compute_firewall" "spoke_allow_ctl_plane" {
  count = var.restrict_egress && var.enable_frontend && var.enable_backend ? 1 : 0

  name    = "${var.prefix}-spoke-${var.suffix}-to-databricks-control-plane"
  project = var.spoke_vpc_google_project
  network = var.spoke_vpc_self_link

  direction = "EGRESS"
  priority  = 1000
  destination_ranges = [
    "${google_compute_forwarding_rule.backend_fr[0].ip_address}/32",
    "${google_compute_forwarding_rule.frontend_fr_spoke[0].ip_address}/32"
  ]

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
}

# === Spoke allow managed Hive (conditional on hive_metastore_ip) ========
resource "google_compute_firewall" "spoke_allow_hive" {
  count = var.restrict_egress && local.hive_metastore_ip != "" ? 1 : 0

  name    = "${var.prefix}-spoke-${var.suffix}-to-${var.google_region}-managed-hive"
  project = var.spoke_vpc_google_project
  network = var.spoke_vpc_self_link

  direction          = "EGRESS"
  priority           = 1000
  destination_ranges = ["${local.hive_metastore_ip}/32"]

  allow {
    protocol = "tcp"
    ports    = ["3306"]
  }
}

# === Hub ingress from spoke =============================================
resource "google_compute_firewall" "hub_ingress" {
  count = var.restrict_egress && local.hub_present ? 1 : 0

  name    = "${var.prefix}-hub-${var.suffix}-ingress"
  project = var.hub_vpc_google_project
  network = var.hub_vpc_self_link

  direction          = "INGRESS"
  priority           = 1000
  destination_ranges = []
  source_ranges      = [var.spoke_vpc_cidr]

  allow {
    protocol = "all"
  }
}
```

- [ ] **Step 2: Write `tests/no-egress/main.tf`**

```hcl
terraform {
  required_version = ">= 1.5"
}

provider "google" {
  project = "fixture-spoke"
  region  = "us-central1"
}

module "pc" {
  source = "../.."

  prefix        = "fixture"
  suffix        = "abc123"
  google_region = "us-central1"

  spoke_vpc_id             = "projects/fixture-spoke/global/networks/spoke-vpc"
  spoke_vpc_self_link      = "https://www.googleapis.com/compute/v1/projects/fixture-spoke/global/networks/spoke-vpc"
  spoke_vpc_google_project = "fixture-spoke"
  spoke_vpc_cidr           = "10.0.0.0/16"

  enable_frontend = true
  enable_backend  = false
  restrict_egress = false
  psc_subnet_cidr = "10.0.255.0/28"
}
```

- [ ] **Step 3: Validate both fixtures**

```bash
cd modules/gcp/private-connectivity/tests/full-isolated && terraform init -backend=false && terraform validate && terraform plan -refresh=false
```

Expected: `Plan: 12 to add` (7 from Task 7 + 5 firewall rules: deny + google-apis + ctl-plane + hive (only if `hive_metastore_ip` set, which it's not in the fixture — so 0) + hub-ingress = 4 firewall rules in this fixture → 11 total. If `hive_metastore_ip` is set in the fixture, expect 12).

Note: fixture has `hive_metastore_ip` unset and `default_hive_metastore_ips` map is empty → `local.hive_metastore_ip = ""` → hive firewall is NOT emitted. So fixture should plan: 7 PSC + 4 firewall = 11 resources.

```bash
cd ../no-egress && terraform init -backend=false && terraform validate && terraform plan -refresh=false
```

Expected: `Plan: 3 to add` (PSC subnet + 1 frontend address + 1 frontend forwarding rule).

- [ ] **Step 4: Commit**

```bash
git add modules/gcp/private-connectivity/
git commit -m "$(cat <<'EOF'
feat(gcp/private-connectivity): add egress firewall stack

Spoke deny-egress (priority 1100), allow-google-apis, allow control
plane (to PSC IPs), allow managed-hive (conditional on metastore IP),
and hub ingress from spoke CIDR. All gated on restrict_egress.

Co-authored-by: Isaac
EOF
)"
```

---

### Task 9: `modules/gcp/account` — scaffold + variables + versions

**Files:**
- Create: `modules/gcp/account/versions.tf`
- Create: `modules/gcp/account/variables.tf`
- Create: `modules/gcp/account/main.tf`
- Create: `modules/gcp/account/vpc-endpoints.tf`
- Create: `modules/gcp/account/pas.tf`
- Create: `modules/gcp/account/outputs.tf`
- Create: `modules/gcp/account/Makefile`
- Create: `modules/gcp/account/README.md`

- [ ] **Step 1: `versions.tf`**

```hcl
terraform {
  required_version = ">= 1.5"
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = ">= 1.0"
    }
  }
}
```

- [ ] **Step 2: `variables.tf`**

```hcl
variable "prefix"                { type = string }
variable "suffix"                { type = string }
variable "workspace_name"        { type = string  default = null }
variable "databricks_account_id" { type = string }
variable "google_project"        { type = string }
variable "google_region"         { type = string }

variable "vpc_source" {
  type        = string
  validation {
    condition     = contains(["databricks_managed", "create", "existing"], var.vpc_source)
    error_message = "vpc_source must be one of: databricks_managed, create, existing."
  }
}

variable "spoke_vpc_name"           { type = string  default = null }
variable "spoke_subnet_name"        { type = string  default = null }
variable "spoke_vpc_google_project" { type = string  default = null }
variable "hub_vpc_google_project"   { type = string  default = null }

# Forwarding-rule names from private-connectivity module (gate vpc_endpoint creation)
variable "frontend_psc_fr_id"     { type = string  default = null }
variable "backend_psc_fr_id"      { type = string  default = null }
variable "hub_frontend_psc_fr_id" { type = string  default = null }

variable "enable_frontend"     { type = bool  default = false }
variable "enable_backend"      { type = bool  default = false }
variable "private_access_only" { type = bool  default = false }

variable "nat_dependency" {
  type        = any
  default     = null
  description = "Opaque value used as depends_on for the workspace to ensure NAT readiness"
}
```

- [ ] **Step 3: Empty `main.tf`, `vpc-endpoints.tf`, `pas.tf`, `outputs.tf` placeholders**

`main.tf`:

```hcl
locals {
  workspace_name      = coalesce(var.workspace_name, "${var.prefix}-ws-${var.suffix}")
  emit_mws_networks   = var.vpc_source != "databricks_managed"
  emit_vpc_endpoints  = var.frontend_psc_fr_id != null && var.backend_psc_fr_id != null
  emit_pas            = var.private_access_only
}
```

`outputs.tf`:

```hcl
output "workspace_id"  { value = null  description = "Databricks workspace ID" }
output "workspace_url" { value = null  description = "Databricks workspace URL" }
output "network_id"    { value = null  description = "mws_networks ID (null when databricks_managed)" }
output "frontend_endpoint_id" { value = null  description = "Frontend mws_vpc_endpoint ID (null when no PSC)" }
output "backend_endpoint_id"  { value = null  description = "Backend mws_vpc_endpoint ID (null when no PSC)" }
output "transit_endpoint_id"  { value = null  description = "Hub-side mws_vpc_endpoint ID (null when no hub)" }
```

`Makefile`:

```makefile
.PHONY: docs test_docs

docs:
	terraform-docs -c ../../../.terraform-docs.yml .

test_docs:
	terraform-docs -c ../../../.terraform-docs.yml --output-check .
```

`README.md`:

```markdown
# modules/gcp/account

All `databricks_mws_*` resources for the GCP composer: `mws_networks`, `mws_workspaces`, `mws_vpc_endpoint`, `mws_private_access_settings`.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
```

- [ ] **Step 4: Validate**

```bash
cd modules/gcp/account && terraform init -backend=false && terraform validate
```

Expected: validate passes.

- [ ] **Step 5: Commit**

```bash
git add modules/gcp/account/
git commit -m "$(cat <<'EOF'
feat(gcp/account): scaffold module

Adds modules/gcp/account with variable declarations, locals for
derived flags, empty main.tf/vpc-endpoints.tf/pas.tf, null outputs.
Resources added in follow-up tasks.

Co-authored-by: Isaac
EOF
)"
```

---

### Task 10: `modules/gcp/account` — databricks-managed workspace shape + fixture

**Files:**
- Modify: `modules/gcp/account/main.tf`
- Modify: `modules/gcp/account/outputs.tf`
- Create: `modules/gcp/account/tests/databricks-managed/main.tf`

- [ ] **Step 1: Write fixture**

```hcl
terraform {
  required_version = ">= 1.5"
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
  }
}

provider "databricks" {
  host       = "https://accounts.gcp.databricks.com"
  account_id = "00000000-0000-0000-0000-000000000000"
}

module "account" {
  source = "../.."

  prefix                = "fixture"
  suffix                = "abc123"
  databricks_account_id = "00000000-0000-0000-0000-000000000000"
  google_project        = "fixture-workspace"
  google_region         = "us-central1"
  vpc_source            = "databricks_managed"
}
```

- [ ] **Step 2: Add `databricks_mws_workspaces` to `main.tf`**

Append to `modules/gcp/account/main.tf`:

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

- [ ] **Step 3: Wire workspace outputs**

```hcl
output "workspace_id" {
  value       = databricks_mws_workspaces.this.workspace_id
  description = "Databricks workspace ID"
}

output "workspace_url" {
  value       = databricks_mws_workspaces.this.workspace_url
  description = "Databricks workspace URL"
}
```

- [ ] **Step 4: Validate fixture**

```bash
cd modules/gcp/account/tests/databricks-managed
terraform init -backend=false
terraform validate
```

Expected: validate passes. (Plan cannot run without real Databricks credentials; validate is sufficient for this fixture.)

- [ ] **Step 5: Commit**

```bash
git add modules/gcp/account/
git commit -m "$(cat <<'EOF'
feat(gcp/account): add databricks_mws_workspaces resource

Workspace resource with conditional network_id and
private_access_settings_id (both null when databricks_managed).

Co-authored-by: Isaac
EOF
)"
```

---

### Task 11: `modules/gcp/account` — mws_networks (customer VPC) + fixture

**Files:**
- Modify: `modules/gcp/account/main.tf`
- Modify: `modules/gcp/account/outputs.tf`
- Create: `modules/gcp/account/tests/byovpc/main.tf`

- [ ] **Step 1: Write fixture**

```hcl
terraform {
  required_version = ">= 1.5"
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
  }
}

provider "databricks" {
  host       = "https://accounts.gcp.databricks.com"
  account_id = "00000000-0000-0000-0000-000000000000"
}

module "account" {
  source = "../.."

  prefix                   = "fixture"
  suffix                   = "abc123"
  databricks_account_id    = "00000000-0000-0000-0000-000000000000"
  google_project           = "fixture-workspace"
  google_region            = "us-central1"
  vpc_source               = "create"
  spoke_vpc_name           = "fixture-spoke-vpc-abc123"
  spoke_subnet_name        = "fixture-subnet-abc123"
  spoke_vpc_google_project = "fixture-spoke"
}
```

- [ ] **Step 2: Append `databricks_mws_networks` to `main.tf`**

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

- [ ] **Step 3: Wire `network_id` output**

```hcl
output "network_id" {
  value       = local.emit_mws_networks ? databricks_mws_networks.this[0].network_id : null
  description = "mws_networks ID (null when databricks_managed)"
}
```

- [ ] **Step 4: Validate fixture**

```bash
cd modules/gcp/account/tests/byovpc
terraform init -backend=false
terraform validate
```

Expected: validate passes (note: references to `databricks_mws_vpc_endpoint.backend[0]` and `frontend[0]` resolve at plan time even if `emit_vpc_endpoints` is false because they're inside a `dynamic` block; the for_each guard prevents evaluation).

- [ ] **Step 5: Commit**

```bash
git add modules/gcp/account/
git commit -m "$(cat <<'EOF'
feat(gcp/account): add databricks_mws_networks for customer VPC

mws_networks emitted when vpc_source != databricks_managed; the
vpc_endpoints block is conditionally populated via dynamic when both
frontend and backend forwarding-rule IDs are provided.

Co-authored-by: Isaac
EOF
)"
```

---

### Task 12: `modules/gcp/account` — mws_vpc_endpoint resources + fixture

**Files:**
- Modify: `modules/gcp/account/vpc-endpoints.tf`
- Modify: `modules/gcp/account/outputs.tf`
- Create: `modules/gcp/account/tests/psc-with-pas/main.tf`

- [ ] **Step 1: Write `vpc-endpoints.tf`**

```hcl
resource "databricks_mws_vpc_endpoint" "frontend" {
  count = var.enable_frontend && var.frontend_psc_fr_id != null ? 1 : 0

  account_id        = var.databricks_account_id
  vpc_endpoint_name = "${var.prefix}-ws-ep-${var.suffix}"

  gcp_vpc_endpoint_info {
    project_id        = var.spoke_vpc_google_project
    psc_endpoint_name = var.frontend_psc_fr_id
    endpoint_region   = var.google_region
  }
}

resource "databricks_mws_vpc_endpoint" "backend" {
  count = var.enable_backend && var.backend_psc_fr_id != null ? 1 : 0

  account_id        = var.databricks_account_id
  vpc_endpoint_name = "${var.prefix}-scc-ep-${var.suffix}"

  gcp_vpc_endpoint_info {
    project_id        = var.spoke_vpc_google_project
    psc_endpoint_name = var.backend_psc_fr_id
    endpoint_region   = var.google_region
  }
}

resource "databricks_mws_vpc_endpoint" "transit" {
  count = var.enable_frontend && var.hub_frontend_psc_fr_id != null ? 1 : 0

  account_id        = var.databricks_account_id
  vpc_endpoint_name = "${var.prefix}-hub-ep-${var.suffix}"

  gcp_vpc_endpoint_info {
    project_id        = var.hub_vpc_google_project
    psc_endpoint_name = var.hub_frontend_psc_fr_id
    endpoint_region   = var.google_region
  }
}
```

- [ ] **Step 2: Wire endpoint outputs**

```hcl
output "frontend_endpoint_id" {
  value       = var.enable_frontend && var.frontend_psc_fr_id != null ? databricks_mws_vpc_endpoint.frontend[0].vpc_endpoint_id : null
  description = "Frontend mws_vpc_endpoint ID (null when no PSC)"
}

output "backend_endpoint_id" {
  value       = var.enable_backend && var.backend_psc_fr_id != null ? databricks_mws_vpc_endpoint.backend[0].vpc_endpoint_id : null
  description = "Backend mws_vpc_endpoint ID (null when no PSC)"
}

output "transit_endpoint_id" {
  value       = var.enable_frontend && var.hub_frontend_psc_fr_id != null ? databricks_mws_vpc_endpoint.transit[0].vpc_endpoint_id : null
  description = "Hub-side mws_vpc_endpoint ID (null when no hub)"
}
```

- [ ] **Step 3: Write fixture `tests/psc-with-pas/main.tf`**

```hcl
terraform {
  required_version = ">= 1.5"
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
  }
}

provider "databricks" {
  host       = "https://accounts.gcp.databricks.com"
  account_id = "00000000-0000-0000-0000-000000000000"
}

module "account" {
  source = "../.."

  prefix                   = "fixture"
  suffix                   = "abc123"
  databricks_account_id    = "00000000-0000-0000-0000-000000000000"
  google_project           = "fixture-workspace"
  google_region            = "us-central1"
  vpc_source               = "create"
  spoke_vpc_name           = "fixture-spoke-vpc-abc123"
  spoke_subnet_name        = "fixture-subnet-abc123"
  spoke_vpc_google_project = "fixture-spoke"
  hub_vpc_google_project   = "fixture-hub"

  frontend_psc_fr_id     = "fixture-psc-ws-ep-abc123"
  backend_psc_fr_id      = "fixture-psc-scc-ep-abc123"
  hub_frontend_psc_fr_id = "fixture-hub-psc-ws-ep-abc123"

  enable_frontend     = true
  enable_backend      = true
  private_access_only = true
}
```

- [ ] **Step 4: Validate**

```bash
cd modules/gcp/account/tests/psc-with-pas && terraform init -backend=false && terraform validate
```

Expected: validate passes.

- [ ] **Step 5: Commit**

```bash
git add modules/gcp/account/
git commit -m "$(cat <<'EOF'
feat(gcp/account): add databricks_mws_vpc_endpoint resources

Frontend, backend (SCC), and transit (hub) mws_vpc_endpoints, each
gated on its enable_* flag and the presence of the corresponding
forwarding-rule name from private-connectivity.

Co-authored-by: Isaac
EOF
)"
```

---

### Task 13: `modules/gcp/account` — private access settings

**Files:**
- Modify: `modules/gcp/account/pas.tf`

- [ ] **Step 1: Write `pas.tf`**

```hcl
resource "databricks_mws_private_access_settings" "this" {
  count = local.emit_pas ? 1 : 0

  account_id                   = var.databricks_account_id
  private_access_settings_name = "${var.prefix}-pas-${var.suffix}"
  region                       = var.google_region
  public_access_enabled        = false
  private_access_level         = "ACCOUNT"
}
```

- [ ] **Step 2: Validate (reuse `tests/psc-with-pas` fixture)**

```bash
cd modules/gcp/account/tests/psc-with-pas && terraform validate
```

Expected: validate passes.

- [ ] **Step 3: Commit**

```bash
git add modules/gcp/account/
git commit -m "$(cat <<'EOF'
feat(gcp/account): add mws_private_access_settings

Emitted when private_access_only=true; public_access_enabled=false,
private_access_level=ACCOUNT. Workspace references via
private_access_settings_id.

Co-authored-by: Isaac
EOF
)"
```

---

### Task 14: `modules/gcp/dns` — scaffold + variables

**Files:**
- Create: `modules/gcp/dns/versions.tf`
- Create: `modules/gcp/dns/variables.tf`
- Create: `modules/gcp/dns/hub.tf` (empty)
- Create: `modules/gcp/dns/spoke.tf` (empty)
- Create: `modules/gcp/dns/outputs.tf`
- Create: `modules/gcp/dns/Makefile`
- Create: `modules/gcp/dns/README.md`

- [ ] **Step 1: `versions.tf`**

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

- [ ] **Step 2: `variables.tf`**

```hcl
variable "prefix"        { type = string }
variable "google_region" { type = string }

# Hub
variable "hub_vpc_id"             { type = string }
variable "hub_vpc_self_link"      { type = string }
variable "hub_vpc_google_project" { type = string }

# Spoke
variable "spoke_vpc_id"             { type = string }
variable "spoke_vpc_self_link"      { type = string }
variable "spoke_vpc_google_project" { type = string }

# Workspace
variable "workspace_url" { type = string }

# PSC IPs
variable "frontend_psc_ip_spoke" { type = string }
variable "frontend_psc_ip_hub"   { type = string  default = null }
variable "backend_psc_ip_spoke"  { type = string }
```

- [ ] **Step 3: Empty `outputs.tf`, `Makefile`, `README.md`**

`outputs.tf`:

```hcl
# This module has no outputs; DNS records are terminal.
```

`Makefile`: same template as Task 6.

`README.md`:

```markdown
# modules/gcp/dns

Private DNS zones (hub + spoke) used with restricted-egress workspaces.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
```

- [ ] **Step 4: Validate**

```bash
cd modules/gcp/dns && terraform init -backend=false && terraform validate
```

Expected: validate passes.

- [ ] **Step 5: Commit**

```bash
git add modules/gcp/dns/
git commit -m "$(cat <<'EOF'
feat(gcp/dns): scaffold module with variables

Variable declarations for hub + spoke DNS zones. Resources added in
follow-up task.

Co-authored-by: Isaac
EOF
)"
```

---

### Task 15: `modules/gcp/dns` — hub + spoke zones and records + fixture

**Files:**
- Modify: `modules/gcp/dns/hub.tf`
- Modify: `modules/gcp/dns/spoke.tf`
- Create: `modules/gcp/dns/tests/hub-and-spoke/main.tf`

- [ ] **Step 1: Write fixture**

```hcl
terraform {
  required_version = ">= 1.5"
}

provider "google" {
  project = "fixture-spoke"
  region  = "us-central1"
}

module "dns" {
  source = "../.."

  prefix        = "fixture"
  google_region = "us-central1"

  hub_vpc_id             = "projects/fixture-hub/global/networks/hub-vpc"
  hub_vpc_self_link      = "https://www.googleapis.com/compute/v1/projects/fixture-hub/global/networks/hub-vpc"
  hub_vpc_google_project = "fixture-hub"

  spoke_vpc_id             = "projects/fixture-spoke/global/networks/spoke-vpc"
  spoke_vpc_self_link      = "https://www.googleapis.com/compute/v1/projects/fixture-spoke/global/networks/spoke-vpc"
  spoke_vpc_google_project = "fixture-spoke"

  workspace_url = "https://1234567890123456.7.gcp.databricks.com"

  frontend_psc_ip_spoke = "10.0.255.4"
  frontend_psc_ip_hub   = "10.1.0.10"
  backend_psc_ip_spoke  = "10.0.255.5"
}
```

- [ ] **Step 2: Write `hub.tf`**

```hcl
locals {
  # Regex extracts the workspace DNS id (numeric.numeric) from the URL.
  # Matches the behavior of the legacy gcp-with-psc-exfiltration-protection module.
  workspace_dns_id = regex("[0-9]+\\.[0-9]+", var.workspace_url)
}

# === gcp.databricks.com (hub) ============================================
resource "google_dns_managed_zone" "hub_dbx" {
  name        = "${var.prefix}-hub-gcp-databricks-com"
  project     = var.hub_vpc_google_project
  dns_name    = "gcp.databricks.com."
  description = "Private DNS zone for Databricks PSC management"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = var.hub_vpc_id
    }
  }
}

resource "google_dns_record_set" "hub_workspace_url" {
  name         = "${local.workspace_dns_id}.${google_dns_managed_zone.hub_dbx.dns_name}"
  project      = var.hub_vpc_google_project
  managed_zone = google_dns_managed_zone.hub_dbx.name
  type         = "A"
  ttl          = 300
  rrdatas      = [var.frontend_psc_ip_hub]
}

resource "google_dns_record_set" "hub_psc_auth" {
  name         = "${var.google_region}.psc-auth.${google_dns_managed_zone.hub_dbx.dns_name}"
  project      = var.hub_vpc_google_project
  managed_zone = google_dns_managed_zone.hub_dbx.name
  type         = "A"
  ttl          = 300
  rrdatas      = [var.frontend_psc_ip_hub]
}

resource "google_dns_record_set" "hub_dp" {
  name         = "dp-${local.workspace_dns_id}.${google_dns_managed_zone.hub_dbx.dns_name}"
  project      = var.hub_vpc_google_project
  managed_zone = google_dns_managed_zone.hub_dbx.name
  type         = "A"
  ttl          = 300
  rrdatas      = [var.frontend_psc_ip_hub]
}

# === gcr.io ==============================================================
resource "google_dns_managed_zone" "gcr" {
  name        = "${var.prefix}-gcr-io"
  project     = var.hub_vpc_google_project
  dns_name    = "gcr.io."
  description = "Private DNS zone for GCR private resolution"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = var.hub_vpc_id
    }
  }
}

resource "google_dns_record_set" "gcr_cname" {
  name         = "*.${google_dns_managed_zone.gcr.dns_name}"
  project      = var.hub_vpc_google_project
  managed_zone = google_dns_managed_zone.gcr.name
  type         = "CNAME"
  ttl          = 300
  rrdatas      = ["gcr.io."]
}

resource "google_dns_record_set" "gcr_a" {
  name         = google_dns_managed_zone.gcr.dns_name
  project      = var.hub_vpc_google_project
  managed_zone = google_dns_managed_zone.gcr.name
  type         = "A"
  ttl          = 300
  rrdatas      = ["199.36.153.8", "199.36.153.9", "199.36.153.10", "199.36.153.11"]
}

# === googleapis.com ======================================================
resource "google_dns_managed_zone" "google_apis" {
  name        = "${var.prefix}-google-apis"
  project     = var.hub_vpc_google_project
  dns_name    = "googleapis.com."
  description = "Private DNS zone for Google APIs resolution"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = var.hub_vpc_id
    }
  }
}

resource "google_dns_record_set" "google_apis_cname" {
  name         = "*.${google_dns_managed_zone.google_apis.dns_name}"
  project      = var.hub_vpc_google_project
  managed_zone = google_dns_managed_zone.google_apis.name
  type         = "CNAME"
  ttl          = 300
  rrdatas      = ["restricted.googleapis.com."]
}

resource "google_dns_record_set" "google_apis_a" {
  name         = "restricted.${google_dns_managed_zone.google_apis.dns_name}"
  project      = var.hub_vpc_google_project
  managed_zone = google_dns_managed_zone.google_apis.name
  type         = "A"
  ttl          = 300
  rrdatas      = ["199.36.153.4", "199.36.153.5", "199.36.153.6", "199.36.153.7"]
}

# === pkg.dev =============================================================
resource "google_dns_managed_zone" "pkg_dev" {
  name        = "${var.prefix}-pkg-dev"
  project     = var.hub_vpc_google_project
  dns_name    = "pkg.dev."
  description = "Private DNS zone for Go Packages resolution"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = var.hub_vpc_id
    }
  }
}

resource "google_dns_record_set" "pkg_dev_cname" {
  name         = "*.${google_dns_managed_zone.pkg_dev.dns_name}"
  project      = var.hub_vpc_google_project
  managed_zone = google_dns_managed_zone.pkg_dev.name
  type         = "CNAME"
  ttl          = 300
  rrdatas      = ["pkg.dev."]
}

resource "google_dns_record_set" "pkg_dev_a" {
  name         = google_dns_managed_zone.pkg_dev.dns_name
  project      = var.hub_vpc_google_project
  managed_zone = google_dns_managed_zone.pkg_dev.name
  type         = "A"
  ttl          = 300
  rrdatas      = ["199.36.153.8", "199.36.153.9", "199.36.153.10", "199.36.153.11"]
}
```

- [ ] **Step 3: Write `spoke.tf`**

```hcl
# === gcp.databricks.com (spoke) ==========================================
resource "google_dns_managed_zone" "spoke_dbx" {
  name        = "${var.prefix}-spoke-gcp-databricks-com"
  project     = var.spoke_vpc_google_project
  dns_name    = "gcp.databricks.com."
  description = "Private DNS zone for Databricks PSC management"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = var.spoke_vpc_id
    }
  }
}

resource "google_dns_record_set" "spoke_workspace_url" {
  name         = "${local.workspace_dns_id}.${google_dns_managed_zone.spoke_dbx.dns_name}"
  project      = var.spoke_vpc_google_project
  managed_zone = google_dns_managed_zone.spoke_dbx.name
  type         = "A"
  ttl          = 300
  rrdatas      = [var.frontend_psc_ip_spoke]
}

resource "google_dns_record_set" "spoke_dp" {
  name         = "dp-${local.workspace_dns_id}.${google_dns_managed_zone.spoke_dbx.dns_name}"
  project      = var.spoke_vpc_google_project
  managed_zone = google_dns_managed_zone.spoke_dbx.name
  type         = "A"
  ttl          = 300
  rrdatas      = [var.frontend_psc_ip_spoke]
}

resource "google_dns_record_set" "spoke_tunnel" {
  name         = "tunnel.${var.google_region}.${google_dns_managed_zone.spoke_dbx.dns_name}"
  project      = var.spoke_vpc_google_project
  managed_zone = google_dns_managed_zone.spoke_dbx.name
  type         = "A"
  ttl          = 300
  rrdatas      = [var.backend_psc_ip_spoke]
}
```

- [ ] **Step 4: Validate fixture**

```bash
cd modules/gcp/dns/tests/hub-and-spoke && terraform init -backend=false && terraform validate && terraform plan -refresh=false
```

Expected: `Plan: 16 to add` (5 zones + 11 record sets: 3 hub_dbx + 2 gcr + 2 google_apis + 2 pkg_dev + 3 spoke = 12. Let me recount: hub_dbx zone + 3 records = 4. gcr zone + 2 records = 3. google_apis zone + 2 records = 3. pkg_dev zone + 2 records = 3. spoke_dbx zone + 3 records = 4. Total = 17).

Expected: `Plan: 17 to add`.

- [ ] **Step 5: Commit**

```bash
git add modules/gcp/dns/
git commit -m "$(cat <<'EOF'
feat(gcp/dns): add hub and spoke private DNS zones

Hub: gcp.databricks.com, gcr.io, googleapis.com, pkg.dev.
Spoke: gcp.databricks.com with workspace/dp/tunnel records.
workspace_dns_id is regex-extracted from workspace_url.

Co-authored-by: Isaac
EOF
)"
```

---

### Task 16: `modules/gcp/databricks-workspace` — composer scaffold + variables

**Files:**
- Create: `modules/gcp/databricks-workspace/versions.tf`
- Create: `modules/gcp/databricks-workspace/variables.tf`
- Create: `modules/gcp/databricks-workspace/main.tf`
- Create: `modules/gcp/databricks-workspace/outputs.tf`
- Create: `modules/gcp/databricks-workspace/Makefile`
- Create: `modules/gcp/databricks-workspace/README.md`

- [ ] **Step 1: `versions.tf`**

```hcl
terraform {
  required_version = ">= 1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = ">= 1.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }
}
```

- [ ] **Step 2: `variables.tf` — full composer API as specified**

```hcl
# === Identity ===========================================================
variable "prefix"                { type = string }
variable "databricks_account_id" { type = string }
variable "google_project"        { type = string }
variable "google_region"         { type = string }
variable "workspace_name"        { type = string  default = null }
variable "tags"                  { type = map(string)  default = {} }

# === VPC source =========================================================
variable "vpc_source" {
  type        = string
  default     = "databricks_managed"
  description = "One of: databricks_managed, create, existing"
  validation {
    condition     = contains(["databricks_managed", "create", "existing"], var.vpc_source)
    error_message = "vpc_source must be one of: databricks_managed, create, existing."
  }
}

# When vpc_source = "create"
variable "spoke_vpc_cidr" { type = string  default = null }
variable "subnet_cidr"    { type = string  default = null }
variable "pod_cidr"       { type = string  default = null }
variable "svc_cidr"       { type = string  default = null }

# When vpc_source = "existing"
variable "existing_vpc_name"    { type = string  default = null }
variable "existing_subnet_name" { type = string  default = null }

# === Connectivity feature flags =========================================
variable "private_link_frontend" { type = bool  default = false }
variable "private_link_backend"  { type = bool  default = false }
variable "private_access_only"   { type = bool  default = false }
variable "restricted_egress"     { type = bool  default = false }

# === Required when restricted_egress = true =============================
variable "hub_vpc_google_project"   { type = string  default = null }
variable "spoke_vpc_google_project" { type = string  default = null }
variable "is_spoke_vpc_shared"      { type = bool    default = false }
variable "hub_vpc_cidr"             { type = string  default = null }
variable "psc_subnet_cidr"          { type = string  default = null }
variable "hive_metastore_ip"        { type = string  default = null }
```

- [ ] **Step 3: `main.tf` — locals, random suffix, preconditions (no submodule wiring yet)**

```hcl
locals {
  databricks_managed = var.vpc_source == "databricks_managed"
  create_vpc         = var.vpc_source == "create"
  use_existing_vpc   = var.vpc_source == "existing"

  any_private_link = var.private_link_frontend || var.private_link_backend
  spoke_project    = coalesce(var.spoke_vpc_google_project, var.google_project)
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false

  lifecycle {
    ignore_changes = [special, upper]
  }
}

# Cross-variable preconditions. Terraform doesn't support cross-var
# validation in variable blocks; we use a null_resource lifecycle.precondition
# stack instead.
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

Note: `null_resource` requires the `hashicorp/null` provider; add it to `versions.tf`. Update `versions.tf`:

```hcl
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
```

- [ ] **Step 4: Empty `outputs.tf`**

```hcl
output "workspace_id"  { value = null  description = "Databricks workspace ID" }
output "workspace_url" { value = null  description = "Databricks workspace URL" }
output "network_id"    { value = null  description = "mws_networks ID (null when databricks_managed)" }
output "vpc_id"        { value = null  description = "Spoke VPC ID (null when databricks_managed)" }
output "spoke_vpc_id"  { value = null  description = "Spoke VPC ID (null when databricks_managed)" }
output "hub_vpc_id"    { value = null  description = "Hub VPC ID (null when not restricted_egress)" }
output "suffix"        { value = random_string.suffix.result  description = "Random suffix used in resource names" }
```

- [ ] **Step 5: Makefile + README placeholder** (same template as previous modules)

- [ ] **Step 6: Validate**

```bash
cd modules/gcp/databricks-workspace && terraform init -backend=false && terraform validate
```

Expected: validate passes.

- [ ] **Step 7: Commit**

```bash
git add modules/gcp/databricks-workspace/
git commit -m "$(cat <<'EOF'
feat(gcp/databricks-workspace): scaffold composer with preconditions

Composer module with full variable API, random_string suffix, locals
for derived flags, and null_resource.preconditions stack enforcing all
cross-variable rules from the spec. Submodule wiring follows in next
tasks.

Co-authored-by: Isaac
EOF
)"
```

---

### Task 17: Composer — wire `network`, `private-connectivity`, `account`, `dns` submodules

**Files:**
- Modify: `modules/gcp/databricks-workspace/main.tf`
- Modify: `modules/gcp/databricks-workspace/outputs.tf`

- [ ] **Step 1: Append submodule blocks to `main.tf`**

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

- [ ] **Step 2: Wire composer outputs**

Replace `outputs.tf`:

```hcl
output "workspace_id" {
  value       = module.account.workspace_id
  description = "Databricks workspace ID"
}

output "workspace_url" {
  value       = module.account.workspace_url
  description = "Databricks workspace URL"
}

output "network_id" {
  value       = module.account.network_id
  description = "mws_networks ID (null when databricks_managed)"
}

output "vpc_id" {
  value       = try(module.network[0].spoke_vpc_id, null)
  description = "Spoke VPC ID (null when databricks_managed)"
}

output "spoke_vpc_id" {
  value       = try(module.network[0].spoke_vpc_id, null)
  description = "Spoke VPC ID (null when databricks_managed)"
}

output "hub_vpc_id" {
  value       = try(module.network[0].hub_vpc_id, null)
  description = "Hub VPC ID (null when not restricted_egress)"
}

output "suffix" {
  value       = random_string.suffix.result
  description = "Random suffix used in resource names"
}
```

- [ ] **Step 3: Validate**

```bash
cd modules/gcp/databricks-workspace && terraform init -backend=false && terraform validate
```

Expected: validate passes.

- [ ] **Step 4: Commit**

```bash
git add modules/gcp/databricks-workspace/
git commit -m "$(cat <<'EOF'
feat(gcp/databricks-workspace): wire submodules in composer

Conditional module blocks for network, private-connectivity, dns
(each gated by appropriate flags) and always-on account module.
Composer outputs wired to module outputs with try() for nullable
network outputs.

Co-authored-by: Isaac
EOF
)"
```

---

### Task 18: Composer — positive fixtures (basic / byovpc / existing / psc-isolated)

**Files:**
- Create: `modules/gcp/databricks-workspace/tests/basic/main.tf`
- Create: `modules/gcp/databricks-workspace/tests/byovpc/main.tf`
- Create: `modules/gcp/databricks-workspace/tests/existing-vpc/main.tf`
- Create: `modules/gcp/databricks-workspace/tests/psc-isolated/main.tf`

Each fixture follows this pattern:

- [ ] **Step 1: Write `tests/basic/main.tf`**

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

module "workspace" {
  source = "../.."

  prefix                = "fixture"
  databricks_account_id = "00000000-0000-0000-0000-000000000000"
  google_project        = "fixture-workspace"
  google_region         = "us-central1"

  vpc_source = "databricks_managed"
}
```

- [ ] **Step 2: Write `tests/byovpc/main.tf`**

Same provider block, then:

```hcl
module "workspace" {
  source = "../.."

  prefix                = "fixture"
  databricks_account_id = "00000000-0000-0000-0000-000000000000"
  google_project        = "fixture-workspace"
  google_region         = "us-central1"

  vpc_source     = "create"
  spoke_vpc_cidr = "10.0.0.0/16"
  subnet_cidr    = "10.0.0.0/22"
}
```

- [ ] **Step 3: Write `tests/existing-vpc/main.tf`**

```hcl
module "workspace" {
  source = "../.."

  prefix                = "fixture"
  databricks_account_id = "00000000-0000-0000-0000-000000000000"
  google_project        = "fixture-workspace"
  google_region         = "us-central1"

  vpc_source           = "existing"
  existing_vpc_name    = "preexisting-vpc"
  existing_subnet_name = "preexisting-subnet"
}
```

- [ ] **Step 4: Write `tests/psc-isolated/main.tf`**

```hcl
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
  private_access_only   = true
  restricted_egress     = true

  spoke_vpc_google_project = "fixture-spoke"
  hub_vpc_google_project   = "fixture-hub"
  is_spoke_vpc_shared      = true
  hub_vpc_cidr             = "10.1.0.0/24"
  psc_subnet_cidr          = "10.0.255.0/28"
}
```

- [ ] **Step 5: Validate every fixture**

```bash
for d in basic byovpc existing-vpc psc-isolated; do
  echo "=== $d ===" && cd modules/gcp/databricks-workspace/tests/$d && \
  terraform init -backend=false && terraform validate && cd -
done
```

Expected: all four validate passes.

- [ ] **Step 6: Commit**

```bash
git add modules/gcp/databricks-workspace/tests/
git commit -m "$(cat <<'EOF'
test(gcp/databricks-workspace): positive fixtures for 4 scenarios

basic (databricks_managed), byovpc (create), existing-vpc (existing),
and psc-isolated (create + all PSC flags + restricted_egress).
Each fixture validates the full module graph.

Co-authored-by: Isaac
EOF
)"
```

---

### Task 19: Composer — negative fixtures (precondition failures)

**Files:**
- Create: `modules/gcp/databricks-workspace/tests/negative-restricted-egress-managed/main.tf`
- Create: `modules/gcp/databricks-workspace/tests/negative-restricted-egress-missing-hub/main.tf`
- Create: `modules/gcp/databricks-workspace/tests/negative-existing-missing-name/main.tf`
- Create: `modules/gcp/databricks-workspace/tests/negative-managed-with-psc/main.tf`

- [ ] **Step 1: Write each fixture**

`negative-restricted-egress-managed/main.tf` (expect: precondition error "restricted_egress=true requires vpc_source=create"):

```hcl
terraform {
  required_version = ">= 1.5"
  required_providers {
    databricks = { source = "databricks/databricks" }
    google     = { source = "hashicorp/google" }
  }
}

provider "google"     { project = "f"  region = "us-central1" }
provider "databricks" { host = "https://accounts.gcp.databricks.com"  account_id = "00000000-0000-0000-0000-000000000000" }

module "workspace" {
  source = "../.."

  prefix                = "fixture"
  databricks_account_id = "00000000-0000-0000-0000-000000000000"
  google_project        = "f"
  google_region         = "us-central1"

  vpc_source        = "databricks_managed"
  restricted_egress = true
}
```

`negative-restricted-egress-missing-hub/main.tf`:

```hcl
# same provider/header
module "workspace" {
  source = "../.."

  prefix                = "fixture"
  databricks_account_id = "00000000-0000-0000-0000-000000000000"
  google_project        = "f"
  google_region         = "us-central1"

  vpc_source            = "create"
  spoke_vpc_cidr        = "10.0.0.0/16"
  subnet_cidr           = "10.0.0.0/22"
  private_link_frontend = true
  private_link_backend  = true
  restricted_egress     = true
  # hub_vpc_google_project, hub_vpc_cidr, psc_subnet_cidr all null -> precondition fail
}
```

`negative-existing-missing-name/main.tf`:

```hcl
module "workspace" {
  source = "../.."

  prefix                = "fixture"
  databricks_account_id = "00000000-0000-0000-0000-000000000000"
  google_project        = "f"
  google_region         = "us-central1"

  vpc_source = "existing"
  # existing_vpc_name / existing_subnet_name null -> precondition fail
}
```

`negative-managed-with-psc/main.tf`:

```hcl
module "workspace" {
  source = "../.."

  prefix                = "fixture"
  databricks_account_id = "00000000-0000-0000-0000-000000000000"
  google_project        = "f"
  google_region         = "us-central1"

  vpc_source            = "databricks_managed"
  private_link_frontend = true   # forbidden with databricks_managed
}
```

- [ ] **Step 2: Verify each fixture fails at plan time**

```bash
for d in negative-restricted-egress-managed negative-restricted-egress-missing-hub negative-existing-missing-name negative-managed-with-psc; do
  echo "=== $d ===" && cd modules/gcp/databricks-workspace/tests/$d && \
  terraform init -backend=false && \
  if terraform plan -refresh=false; then
    echo "FAIL: $d should have failed plan"; exit 1
  else
    echo "OK: $d failed plan as expected"
  fi && cd -
done
```

Expected: each fixture fails at plan time with a precondition error message matching the spec table.

- [ ] **Step 3: Commit**

```bash
git add modules/gcp/databricks-workspace/tests/
git commit -m "$(cat <<'EOF'
test(gcp/databricks-workspace): negative fixtures for preconditions

Four fixtures, each violating one precondition rule from the spec.
Each fixture must fail `terraform plan` with a clear error message.

Co-authored-by: Isaac
EOF
)"
```

---

### Task 20: Relocate `modules/gcp-sa-provisioning` → `modules/gcp/service-account`

**Files:**
- Move: `modules/gcp-sa-provisioning/` → `modules/gcp/service-account/`
- Create: `modules/gcp-sa-provisioning/README.md` (deprecation stub)

- [ ] **Step 1: `git mv` the directory**

```bash
git mv modules/gcp-sa-provisioning modules/gcp/service-account
```

- [ ] **Step 2: Update the Makefile path inside the relocated module**

Read `modules/gcp/service-account/Makefile`. The relative path to `.terraform-docs.yml` needs to deepen by one level: `../../.terraform-docs.yml` → `../../../.terraform-docs.yml`. Edit:

```makefile
.PHONY: docs test_docs

docs:
	terraform-docs -c ../../../.terraform-docs.yml .

test_docs:
	terraform-docs -c ../../../.terraform-docs.yml --output-check .
```

- [ ] **Step 3: Create deprecation stub at the old path**

```bash
mkdir -p modules/gcp-sa-provisioning
```

Write `modules/gcp-sa-provisioning/README.md`:

```markdown
# DEPRECATED — moved to `modules/gcp/service-account/`

This module has been relocated to [`../gcp/service-account/`](../gcp/service-account/).

All variables, outputs, and resource addresses are unchanged. Update your
module `source` from:

```hcl
source = "github.com/databricks/terraform-databricks-examples/modules/gcp-sa-provisioning"
```

to:

```hcl
source = "github.com/databricks/terraform-databricks-examples/modules/gcp/service-account"
```

This stub will be removed in PR 6 of the GCP modules refactor.
```

- [ ] **Step 4: Validate the relocated module**

```bash
cd modules/gcp/service-account && terraform init -backend=false && terraform validate
```

Expected: validate passes (no functional changes).

- [ ] **Step 5: Commit**

```bash
git add modules/gcp/service-account/ modules/gcp-sa-provisioning/README.md
git commit -m "$(cat <<'EOF'
refactor(gcp/service-account): relocate from modules/gcp-sa-provisioning

git mv only; no functional changes. Old path has a deprecation README
pointing to the new location. Makefile updated for new depth.

Co-authored-by: Isaac
EOF
)"
```

---

### Task 21: Relocate `modules/gcp-unity-catalog` → `modules/gcp/unity-catalog`

Same pattern as Task 20.

- [ ] **Step 1: `git mv`**

```bash
git mv modules/gcp-unity-catalog modules/gcp/unity-catalog
```

- [ ] **Step 2: Update `modules/gcp/unity-catalog/Makefile`** to use `../../../.terraform-docs.yml`.

- [ ] **Step 3: Write `modules/gcp-unity-catalog/README.md`** (deprecation stub, same template as Task 20).

- [ ] **Step 4: Validate**

```bash
cd modules/gcp/unity-catalog && terraform init -backend=false && terraform validate
```

- [ ] **Step 5: Commit**

```bash
git add modules/gcp/unity-catalog/ modules/gcp-unity-catalog/README.md
git commit -m "$(cat <<'EOF'
refactor(gcp/unity-catalog): relocate from modules/gcp-unity-catalog

git mv only; no functional changes. Old path has a deprecation README.

Co-authored-by: Isaac
EOF
)"
```

---

### Task 22: Regenerate `terraform-docs` READMEs for all new modules

**Files:**
- Modify: `modules/gcp/*/README.md` (every submodule, via `terraform-docs`)

- [ ] **Step 1: Run `make docs` recursively**

```bash
make -C modules/gcp docs
```

Expected: each module's README has its `<!-- BEGIN_TF_DOCS -->` ... `<!-- END_TF_DOCS -->` block populated with inputs/outputs tables.

- [ ] **Step 2: Verify `pre-commit` passes**

```bash
pre-commit run --all-files
```

Expected: all hooks pass (terraform_fmt, terraform_validate, terraform_docs).

- [ ] **Step 3: Commit**

```bash
git add modules/gcp/
git commit -m "$(cat <<'EOF'
docs(gcp): regenerate terraform-docs for all new submodules

Generated README content for network, private-connectivity, account,
dns, and databricks-workspace via `make -C modules/gcp docs`.

Co-authored-by: Isaac
EOF
)"
```

---

### Task 23: Open PR 1 (draft)

- [ ] **Step 1: Push branch**

```bash
git push -u origin feature/gcp-modules-refactor
```

- [ ] **Step 2: Open draft PR**

```bash
gh pr create --draft --title "feat(gcp): add modules/gcp/ composer + submodules (PR 1 of 6)" --body "$(cat <<'EOF'
## Summary

First PR of the GCP modules refactor described in `docs/superpowers/specs/2026-05-14-gcp-modules-refactor-design.md`. Adds:

- `modules/gcp/databricks-workspace` — top-level composer
- `modules/gcp/network` — VPC/subnet/router/NAT/peering/shared-VPC
- `modules/gcp/private-connectivity` — PSC + egress firewall
- `modules/gcp/account` — all `databricks_mws_*` resources
- `modules/gcp/dns` — private DNS zones (hub + spoke)
- Relocations: `modules/gcp-sa-provisioning` → `modules/gcp/service-account`, `modules/gcp-unity-catalog` → `modules/gcp/unity-catalog`

No example consumes these yet — they will be migrated one PR at a time.

## Test plan

- [ ] `pre-commit run --all-files` passes
- [ ] Every fixture under `modules/gcp/*/tests/<scenario>/` validates
- [ ] Every negative fixture under `modules/gcp/databricks-workspace/tests/negative-*/` fails at plan time
EOF
)"
```

---

## PR 2 — Migrate `examples/gcp-basic`

### Task 24: Rewrite `examples/gcp-basic` against the new composer

**Files:**
- Modify: `examples/gcp-basic/main.tf`
- Modify: `examples/gcp-basic/variables.tf`
- Modify: `examples/gcp-basic/outputs.tf`
- Modify: `examples/gcp-basic/README.md`
- Modify: `examples/gcp-basic/terraform.tfvars`
- (Leave `init.tf` and `Makefile` unchanged.)

- [ ] **Step 1: Rewrite `main.tf`**

```hcl
module "workspace" {
  source = "../../modules/gcp/databricks-workspace"

  prefix                = var.prefix
  databricks_account_id = var.databricks_account_id
  google_project        = var.google_project
  google_region         = var.google_region
  workspace_name        = var.workspace_name

  vpc_source = "databricks_managed"
}
```

- [ ] **Step 2: Trim `variables.tf` to only what this example needs**

```hcl
variable "databricks_account_id" {
  type        = string
  description = "Databricks Account ID"
}

variable "databricks_google_service_account" {
  type        = string
  description = "Service account email used for Databricks provider authentication"
}

variable "google_project" {
  type        = string
  description = "GCP project where the workspace will be created"
}

variable "google_region" {
  type        = string
  description = "GCP region for workspace deployment"
}

variable "google_zone" {
  type        = string
  description = "GCP zone (used by the google provider)"
}

variable "prefix" {
  type        = string
  description = "Prefix used to name generated resources"
}

variable "workspace_name" {
  type        = string
  description = "Workspace name"
}
```

(Drop `delegate_from` — that variable belongs to SA-provisioning, not basic.)

- [ ] **Step 3: Rewrite `outputs.tf`**

```hcl
output "workspace_id" {
  value       = module.workspace.workspace_id
  description = "Databricks workspace ID"
}

output "workspace_url" {
  value       = module.workspace.workspace_url
  description = "Databricks workspace URL"
}
```

- [ ] **Step 4: Update `terraform.tfvars` skeleton**

```hcl
databricks_account_id             = ""
databricks_google_service_account = ""
google_project                    = ""
google_region                     = ""
google_zone                       = ""
prefix                            = ""
workspace_name                    = ""
```

- [ ] **Step 5: Rewrite `README.md`**

```markdown
# examples/gcp-basic — Databricks-managed VPC

Calls `modules/gcp/databricks-workspace` with `vpc_source = "databricks_managed"`.
The Databricks platform provisions the workspace VPC; you provide only the GCP
project, region, and prefix.

## Prerequisites

- A GCP project with the Databricks platform onboarded
- A service account with workspace-creator role (see `examples/gcp-sa-provisioning`)
- Databricks account ID

## Apply

```bash
terraform init
terraform apply
```

## Migrating from the old example

This example previously called `modules/gcp-workspace-basic`. State from the
old apply does **not** migrate cleanly to the new composer because the
`databricks_mws_workspaces` resource address differs. Re-apply on clean state.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
```

- [ ] **Step 6: Regenerate docs and validate**

```bash
cd examples/gcp-basic && make docs && terraform init -backend=false && terraform validate
```

Expected: validate passes.

- [ ] **Step 7: Sandbox apply (manual)**

The author runs `terraform apply` against a sandbox project and confirms the workspace is reachable. Capture plan output as a PR comment. Run `terraform destroy` after.

- [ ] **Step 8: Commit + open PR**

```bash
git add examples/gcp-basic/
git commit -m "$(cat <<'EOF'
refactor(examples/gcp-basic): migrate to modules/gcp/databricks-workspace

Replaces the call to modules/gcp-workspace-basic with the new composer
using vpc_source="databricks_managed". Variables trimmed to scenario
inputs; README documents the migration caveat.

Co-authored-by: Isaac
EOF
)"

gh pr create --draft --title "refactor(examples/gcp-basic): migrate to new composer (PR 2 of 6)" --body "$(cat <<'EOF'
## Summary

Migrates `examples/gcp-basic` to call `modules/gcp/databricks-workspace`. Old
`modules/gcp-workspace-basic` remains untouched (deleted in PR 6).

## Test plan

- [ ] Sandbox `terraform apply` succeeds; workspace reachable
- [ ] Fresh `terraform plan` shows zero drift after apply
- [ ] `terraform destroy` cleans up without orphans
EOF
)"
```

---

## PR 3 — Migrate `examples/gcp-byovpc`

### Task 25: Rewrite `examples/gcp-byovpc` against the new composer

Same pattern as Task 24, with these differences:

- [ ] **Step 1: `main.tf`**

```hcl
module "workspace" {
  source = "../../modules/gcp/databricks-workspace"

  prefix                = var.prefix
  databricks_account_id = var.databricks_account_id
  google_project        = var.google_project
  google_region         = var.google_region
  workspace_name        = var.workspace_name

  vpc_source     = "create"
  spoke_vpc_cidr = var.spoke_vpc_cidr
  subnet_cidr    = var.subnet_cidr
  pod_cidr       = var.pod_cidr
  svc_cidr       = var.svc_cidr
}
```

- [ ] **Step 2: `variables.tf`**

```hcl
variable "databricks_account_id"             { type = string }
variable "databricks_google_service_account" { type = string }
variable "google_project"                    { type = string }
variable "google_region"                     { type = string }
variable "google_zone"                       { type = string }
variable "prefix"                            { type = string }
variable "workspace_name"                    { type = string }

variable "spoke_vpc_cidr" { type = string }
variable "subnet_cidr"    { type = string }
variable "pod_cidr"       { type = string  default = null }
variable "svc_cidr"       { type = string  default = null }
```

- [ ] **Step 3–8:** Same as Task 24 (outputs, tfvars, README, docs, validate, sandbox apply, commit + PR).

Note: variable names changed — `subnet_ip_cidr_range` → `subnet_cidr`, `pod_ip_cidr_range` → `pod_cidr`, `svc_ip_cidr_range` → `svc_cidr`, etc. README must explicitly call this out:

> **Breaking change for migrating users:** variable names changed to match the new composer (`subnet_ip_cidr_range` → `subnet_cidr`, etc.). Update your tfvars accordingly.

Commit message:

```
refactor(examples/gcp-byovpc): migrate to modules/gcp/databricks-workspace

vpc_source="create" with spoke + subnet CIDRs. Variable names changed
to match the composer; README documents the migration.
```

---

## PR 4 — Migrate `examples/gcp-with-psc-exfiltration-protection`

### Task 26: Rewrite the PSC example against the new composer

**Files:**
- Modify: `examples/gcp-with-psc-exfiltration-protection/main.tf`
- Modify: `examples/gcp-with-psc-exfiltration-protection/unity-catalog.tf`
- Modify: `examples/gcp-with-psc-exfiltration-protection/variables.tf`
- Modify: `examples/gcp-with-psc-exfiltration-protection/outputs.tf`
- Modify: `examples/gcp-with-psc-exfiltration-protection/README.md`
- Modify: `examples/gcp-with-psc-exfiltration-protection/terraform.tfvars`

- [ ] **Step 1: Rewrite `main.tf`**

```hcl
module "workspace" {
  source = "../../modules/gcp/databricks-workspace"

  prefix                = var.prefix
  databricks_account_id = var.databricks_account_id
  google_project        = var.workspace_google_project
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
  hive_metastore_ip        = var.hive_metastore_ip

  tags = var.tags
}
```

- [ ] **Step 2: Rewrite `unity-catalog.tf` to consume composer outputs**

```hcl
module "unity_catalog" {
  source = "../../modules/gcp/unity-catalog"

  providers = {
    databricks           = databricks
    databricks.workspace = databricks.workspace
  }

  databricks_workspace_id  = module.workspace.workspace_id
  databricks_workspace_url = module.workspace.workspace_url
  google_project           = var.workspace_google_project
  google_region            = var.google_region
  prefix                   = var.prefix
  metastore_name           = var.metastore_name
  catalog_name             = var.catalog_name
}
```

- [ ] **Step 3: Trim `variables.tf`**

Drop variables that no longer apply (none — all current vars still map). Rename `subnet_cidr_var` references if any.

Add new required vars: `spoke_vpc_cidr` (was `spoke_vpc_cidr` already), `subnet_cidr` (NEW — split from existing single CIDR var if needed). Refer to the current `terraform.tfvars` to confirm whether `subnet_cidr` was already exposed or needs to be added.

Check current vars file:

```bash
cat examples/gcp-with-psc-exfiltration-protection/variables.tf
```

If `subnet_cidr` isn't there, add:

```hcl
variable "subnet_cidr" {
  type        = string
  description = "CIDR for the spoke subnet"
}
```

- [ ] **Step 4: Update `terraform.tfvars`** to include `subnet_cidr` and remove any orphaned vars.

- [ ] **Step 5: Update README**

Document the migration. Note that `private_link_frontend`, `private_link_backend`, `private_access_only`, `restricted_egress` are now the explicit feature flags; the example sets all four to `true`.

- [ ] **Step 6: Regenerate docs and validate**

```bash
cd examples/gcp-with-psc-exfiltration-protection && make docs && terraform init -backend=false && terraform validate
```

- [ ] **Step 7: Sandbox apply (manual, with extra care)**

- Snapshot state before apply
- Apply against sandbox
- Verify workspace reachable through PSC
- Verify UC catalog accessible
- Fresh plan — confirm zero drift
- `terraform destroy` — confirm PSC + DNS teardown is clean (no orphans)
- Capture all plan/apply/destroy output in the PR description

- [ ] **Step 8: Commit + open PR**

```bash
git add examples/gcp-with-psc-exfiltration-protection/
git commit -m "$(cat <<'EOF'
refactor(examples/gcp-with-psc): migrate to new composer

Single module call to modules/gcp/databricks-workspace with all four
connectivity flags enabled and restricted_egress=true. Unity Catalog
wired separately via modules/gcp/unity-catalog.

Co-authored-by: Isaac
EOF
)"

gh pr create --draft --title "refactor(examples/gcp-with-psc): migrate to new composer (PR 4 of 6)" --body "$(cat <<'EOF'
## Summary

Migrates the PSC + exfiltration-protection example to the new composer.
The most complex of the migration PRs.

## Test plan

- [ ] Sandbox `terraform apply` succeeds end-to-end
- [ ] Workspace reachable through PSC (frontend)
- [ ] UC catalog accessible
- [ ] Fresh `terraform plan` shows zero drift
- [ ] `terraform destroy` cleans up PSC + DNS without orphans
EOF
)"
```

---

## PR 5 — New `examples/gcp-existing-vpc`

### Task 27: Add the new "existing VPC" example

**Files:**
- Create: `examples/gcp-existing-vpc/main.tf`
- Create: `examples/gcp-existing-vpc/init.tf`
- Create: `examples/gcp-existing-vpc/variables.tf`
- Create: `examples/gcp-existing-vpc/outputs.tf`
- Create: `examples/gcp-existing-vpc/terraform.tfvars`
- Create: `examples/gcp-existing-vpc/README.md`
- Create: `examples/gcp-existing-vpc/Makefile`

- [ ] **Step 1: Copy `init.tf` and `Makefile` from `examples/gcp-basic`** (identical provider setup).

- [ ] **Step 2: Write `main.tf`**

```hcl
module "workspace" {
  source = "../../modules/gcp/databricks-workspace"

  prefix                = var.prefix
  databricks_account_id = var.databricks_account_id
  google_project        = var.google_project
  google_region         = var.google_region
  workspace_name        = var.workspace_name

  vpc_source           = "existing"
  existing_vpc_name    = var.existing_vpc_name
  existing_subnet_name = var.existing_subnet_name
}
```

- [ ] **Step 3: Write `variables.tf`**

```hcl
variable "databricks_account_id"             { type = string }
variable "databricks_google_service_account" { type = string }
variable "google_project"                    { type = string }
variable "google_region"                     { type = string }
variable "google_zone"                       { type = string }
variable "prefix"                            { type = string }
variable "workspace_name"                    { type = string }
variable "existing_vpc_name"                 { type = string }
variable "existing_subnet_name"              { type = string }
```

- [ ] **Step 4: Write `outputs.tf`, `terraform.tfvars`, `README.md`** (same templates as Task 24, scenario-appropriate).

- [ ] **Step 5: Validate**

```bash
cd examples/gcp-existing-vpc && make docs && terraform init -backend=false && terraform validate
```

- [ ] **Step 6: Sandbox apply (requires a pre-existing VPC and subnet in the sandbox project)**

- [ ] **Step 7: Commit + PR**

```bash
git add examples/gcp-existing-vpc/
git commit -m "$(cat <<'EOF'
feat(examples/gcp-existing-vpc): new example using existing VPC

New scenario unsupported by the legacy modules. Calls the composer
with vpc_source="existing" and looks up the pre-existing VPC and
subnet via the network submodule's data sources.

Co-authored-by: Isaac
EOF
)"

gh pr create --draft --title "feat(examples/gcp-existing-vpc): new example (PR 5 of 6)" --body "..."
```

---

## PR 6 — Cleanup

### Task 28: Repoint `examples/gcp-sa-provisioning` at the relocated module

**Files:**
- Modify: `examples/gcp-sa-provisioning/main.tf`

- [ ] **Step 1: Update the `source` line**

In `examples/gcp-sa-provisioning/main.tf` change:

```hcl
source = "github.com/databricks/terraform-databricks-examples/modules/gcp-sa-provisioning"
```

to:

```hcl
source = "github.com/databricks/terraform-databricks-examples/modules/gcp/service-account"
```

(Or the relative path `../../modules/gcp/service-account` if the example uses relative sources — match existing convention.)

- [ ] **Step 2: Validate**

```bash
cd examples/gcp-sa-provisioning && terraform init -backend=false && terraform validate
```

- [ ] **Step 3: Commit**

```bash
git add examples/gcp-sa-provisioning/
git commit -m "$(cat <<'EOF'
refactor(examples/gcp-sa-provisioning): repoint to modules/gcp/service-account

Co-authored-by: Isaac
EOF
)"
```

---

### Task 29: Delete deprecated modules

**Files:**
- Delete: `modules/gcp-workspace-basic/`
- Delete: `modules/gcp-workspace-byovpc/`
- Delete: `modules/gcp-with-psc-exfiltration-protection/`
- Delete: `modules/gcp-sa-provisioning/` (deprecation stub from Task 20)
- Delete: `modules/gcp-unity-catalog/` (deprecation stub from Task 21)

- [ ] **Step 1: Confirm no example still references the old paths**

```bash
grep -rn "modules/gcp-workspace-basic\|modules/gcp-workspace-byovpc\|modules/gcp-with-psc-exfiltration-protection\|modules/gcp-sa-provisioning\|modules/gcp-unity-catalog" examples/ modules/
```

Expected: no matches (every match should already point to `modules/gcp/...`).

- [ ] **Step 2: Delete**

```bash
git rm -r modules/gcp-workspace-basic modules/gcp-workspace-byovpc modules/gcp-with-psc-exfiltration-protection modules/gcp-sa-provisioning modules/gcp-unity-catalog
```

- [ ] **Step 3: Commit**

```bash
git commit -m "$(cat <<'EOF'
refactor: remove deprecated GCP modules

Removes modules/gcp-workspace-basic, modules/gcp-workspace-byovpc,
modules/gcp-with-psc-exfiltration-protection, and the deprecation
stubs for modules/gcp-sa-provisioning and modules/gcp-unity-catalog.
All examples now point at modules/gcp/*.

Co-authored-by: Isaac
EOF
)"
```

---

### Task 30: Delete junk directories and stray state files

**Files:**
- Delete: `examples/gcp-sa-provisionning/` (typo dir, only contains a Makefile)
- Delete: `examples/gcp-test-modules/` (only state files)
- Delete: stray `terraform.tfstate*` files under `examples/gcp-*/` (verify `.gitignore` first)

- [ ] **Step 1: Check `.gitignore`**

```bash
grep -n "tfstate" .gitignore
```

Expected: tfstate files should already be gitignored. If not, add patterns and stage that change.

- [ ] **Step 2: Delete junk dirs**

```bash
git rm -r examples/gcp-sa-provisionning examples/gcp-test-modules
```

- [ ] **Step 3: Untrack stray state files**

```bash
git rm --cached examples/gcp-basic/terraform.tfstate* 2>/dev/null || true
git rm --cached examples/gcp-byovpc/terraform.tfstate* 2>/dev/null || true
git rm --cached examples/gcp-with-psc-exfiltration-protection/terraform.tfstate* 2>/dev/null || true
```

- [ ] **Step 4: Commit**

```bash
git commit -m "$(cat <<'EOF'
chore: remove junk dirs and untrack stray terraform state

Deletes examples/gcp-sa-provisionning (typo dir, Makefile only) and
examples/gcp-test-modules (state-only). Untracks accidentally-committed
terraform.tfstate files under examples/gcp-*.

Co-authored-by: Isaac
EOF
)"
```

---

### Task 31: Update top-level README

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Identify the GCP section in the top-level README**

```bash
grep -n -A 5 "gcp" README.md | head -40
```

- [ ] **Step 2: Rewrite the GCP examples table**

Update the listing to:

| Example | Description |
|---------|-------------|
| `examples/gcp-basic` | Databricks-managed VPC |
| `examples/gcp-byovpc` | Customer VPC (Terraform creates it) |
| `examples/gcp-existing-vpc` | Use an existing customer VPC |
| `examples/gcp-with-psc-exfiltration-protection` | Full PSC + private DNS + restricted egress |
| `examples/gcp-sa-provisioning` | Bootstrap the workspace-creator service account |

Update the modules listing to reflect the new structure under `modules/gcp/`.

- [ ] **Step 3: Commit and open final PR**

```bash
git add README.md
git commit -m "$(cat <<'EOF'
docs: update README for new GCP module layout

Updates the GCP examples and modules tables to reflect the
modules/gcp/ composer + submodules and the new gcp-existing-vpc
example.

Co-authored-by: Isaac
EOF
)"

gh pr create --draft --title "chore: delete legacy GCP modules and dirs (PR 6 of 6)" --body "..."
```

---

## Self-Review

(Performed after writing the plan; issues found and fixed inline.)

**1. Spec coverage:**
- Problem statement → Tasks 24–31 migrate every existing GCP example ✓
- Goals 1–7 → All addressed; thin examples in Tasks 24–27 ✓
- Module layout (5 submodules + service-account + unity-catalog) → Tasks 2–22 ✓
- Composer API → Task 16 (variables), Task 17 (wiring), Task 19 (preconditions) ✓
- Cross-variable validation table → Task 19 (negative fixtures verify each rule) ✓
- Submodule contracts → Tasks 2–15 implement each contract ✓
- Example shapes (4 scenarios) → Tasks 18 (composer fixtures) + 24–27 (real examples) ✓
- Migration plan (6 PRs) → Tasks grouped under "PR 1" through "PR 6" headers ✓
- Testing approach → Tasks 18 (positive), 19 (negative), per-task validate steps ✓
- Risks → Hive metastore IP fallback acknowledged via the empty `default_hive_metastore_ips` map; teardown ordering is sandbox-tested in PR 4 ✓

**2. Placeholders:** Scanned for "TBD", "TODO", "implement later", vague "add error handling". Found none. The Hive metastore IP map is intentionally empty initially (variable falls back to "" and gates the hive firewall rule); this is a documented behavior, not a placeholder.

**3. Type consistency:**
- `frontend_psc_fr_id` / `backend_psc_fr_id` / `hub_frontend_psc_fr_id` used consistently across `private-connectivity` outputs (Task 7), `account` inputs (Task 9), and composer wiring (Task 17) ✓
- `spoke_vpc_self_link`, `hub_vpc_self_link` consistent between `network` outputs (Tasks 3, 5), `private-connectivity` inputs (Task 6), and `dns` inputs (Task 14) ✓
- `workspace_url` flows from `account` (Task 10) → `dns` (Task 14, 15) → composer outputs (Task 17) ✓
- `nat_dependency` is `type = any` in `account` (Task 9), wired to `module.network[0].nat_id` (Task 17) — matches ✓

**4. Spec requirements with no task:** None found.

---

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-05-14-gcp-modules-refactor.md`.

Two execution options:

**1. Subagent-Driven (recommended)** — fresh subagent per task, review between tasks, fast iteration.

**2. Inline Execution** — execute tasks in this session using executing-plans, batch execution with checkpoints.

Which approach?
