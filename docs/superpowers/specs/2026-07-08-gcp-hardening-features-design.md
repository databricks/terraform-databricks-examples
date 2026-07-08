# GCP Hardening Fixes, Cross-Cloud Contract & Compute Features — Design Spec

**Date:** 2026-07-08
**Author:** Michele Daddetta
**Status:** Draft (pending user review)
**Branch:** `issue-165/gcp-psc-exfiltration-hardening` (continues PR #233)

## Problem

PR #233 established the GCP composer + submodule architecture, but three things
stand between it and its stated role as the template for rebuilding the whole
repository:

1. **A deep correctness review found 3 blockers and 6 major/medium defects.**
   The flagship PSC scenario cannot `terraform plan` on fresh state, and two
   functional-parity losses versus the deleted `gcp-with-psc-exfiltration-protection`
   module would prevent clusters from launching under restricted egress.
2. **The cross-cloud contract exists only in conversation.** Nothing in the repo
   states which names/flags are frozen for Azure/AWS ports versus which are
   GCP-native dialect. The `account` submodule name doesn't port to Azure at all.
3. **The stack covers only classic-compute networking, circa the old module.**
   Serverless egress control (GA on GCP, Enterprise tier), CMEK (GA), and the
   workspace security settings are absent; the network module still carries
   GKE-era pod/svc secondary ranges that current GCE-based workspaces neither
   need nor use.

## Goals

1. Every blocker/major/medium finding from the submodule review is fixed; the
   `psc-isolated` fixture plans cleanly and restricted-egress parity with the old
   module is restored.
2. A cross-cloud module contract document ships in this PR; the GCP tree is its
   reference implementation.
3. `modules/gcp/account` → `modules/gcp/workspace` (contract slot name).
4. Serverless egress control, CMEK, and a shared security-settings module are
   added; GKE pod/svc CIDRs are removed.
5. NCC (serverless private connectivity) gets a reserved contract slot, no GCP
   code until the feature reaches Public Preview.
6. Sandbox test procedure defined for basic / byovpc / PSC scenarios.

## Non-Goals

- No Azure/AWS code changes (the contract doc constrains future PRs; it doesn't
  retrofit existing modules).
- No state-migration tooling (PR #233 already declares clean-state re-apply).
- No VPC-SC serverless project numbers or stable-outbound-IP automation (both
  preview, neither meaningfully terraformable; README mentions only).
- No maintenance of a hardcoded regional Hive-metastore IP map (see Fix A7).

---

## Phase A — Correctness fixes

Findings numbered as in the review (F1–F13).

### A1. Plan-time-unknown counts (F1, blocker)

`count` must never depend on apply-time values.

- `private-connectivity`: new variable `create_hub` (bool). `locals.hub_present`
  is replaced by `var.create_hub` in `psc.tf` and `firewall.tf`. The composer
  passes `create_hub = var.restricted_egress`.
- `workspace` (née `account`): `vpc-endpoints.tf` counts gate on
  `var.enable_frontend` / `var.enable_backend` / new `var.create_hub` — not on
  forwarding-rule names. `locals.emit_vpc_endpoints` derives from the same flags.
- Acceptance: `tests/psc-isolated` completes `terraform plan` on fresh state.

### A2. Spoke DNS for Google APIs (F2, blocker)

Restore the old module's topology: the hub hosts the private zones
(`googleapis.com`, `gcr.io`, `pkg.dev`) with records; the spoke VPC gets
**peering zones** (`google_dns_managed_zone` with `peering_config` targeting the
hub network) for each of the three domains, exactly as `dns-spoke.tf` did on
main. `gcp.databricks.com` zones stay as they are (already correct both sides).

### A3. Intra-VPC firewall rules (F3, blocker)

Restore to `private-connectivity/firewall.tf`:

- `<prefix>-spoke-egress-intra` — EGRESS allow to `spoke_vpc_cidr`, priority 1000
  (beats the 1100 deny).
- `<prefix>-spoke-ingress-intra` — INGRESS allow from `spoke_vpc_cidr`
  (satisfies the documented `db-<subnet>-ingress` BYOVPC requirement).

### A4. `restricted_egress` requires both PSC flags (F4, major)

The DNS records and control-plane allow rule structurally assume both frontend
and backend PSC. The composer precondition changes from "at least one flag" to
`private_link_frontend && private_link_backend` when `restricted_egress=true`,
with an error message explaining why. (This matches the old module, which had
no single-sided mode.)

### A5. Single-sided PSC endpoint wiring (F5, major)

`databricks_mws_networks.vpc_endpoints` is built dynamically from whichever
endpoints exist (`compact()` over conditionally-null IDs) instead of the
all-or-nothing `emit_vpc_endpoints`. Backend-only PSC then correctly attaches
its endpoint; frontend-only likewise.

### A6. `psc_subnet_cidr` precondition (F6, major)

Precondition 3 extends: `psc_subnet_cidr` is required when
`local.any_private_link || var.restricted_egress` (matching the variable's own
description).

### A7. Hive metastore rule honesty (F7, medium)

Drop the "regional default is looked up internally" promise and the empty map.
`hive_metastore_ip` stays optional: set → allow rule created; null → no rule,
README notes that UC-default workspaces don't need the legacy HMS and points at
the docs for regional IPs. No hardcoded IP map to maintain.

### A8. No NAT under restricted egress (F8, medium)

`network` gains `enable_nat` (bool, default true). The composer passes
`enable_nat = !var.restricted_egress`. The exfiltration-protection topology
again has no internet egress path, matching the old module.

### A9. Shared-VPC gate (F9, medium)

`shared-vpc.tf` gates on `var.is_spoke_vpc_shared && spoke_project != workspace_project`
only — no hub requirement. BYOVPC + Shared VPC is expressible again.

### A10. Dead variables & misdocumentation (F10, minor)

Remove: `network.spoke_vpc_cidr` (unused; description also wrong),
`private-connectivity.hub_vpc_cidr`, `dns.hub_vpc_self_link`,
`dns.spoke_vpc_self_link`. Composer wiring updated. `tags` stays
reserved-for-future (prior decision) but the PSC example stops passing it.

### A11. PAT creation removed (F11-adjacent, behavior)

The `token {}` block in `workspace.tf` is removed — the old module never created
a PAT, tokens don't belong in module state, and examples needing one can create
it explicitly. Called out in the PR description as an intentional difference
from the intermediate state of this branch.

### A12. Provider constraint & deprecation hygiene (F11, F12, minor)

- Resource-level `account_id` removed from all `databricks_mws_*` resources;
  the account-level provider carries it (examples already configure this).
- Constraint policy: modules declare floors (`google >= 6.0`,
  `databricks >= 1.85`); examples pin pessimistically (`~> 6.17`, `~> 1.85`).
  One policy, stated in the contract doc.

### A13. Idiom cleanups (F13, nits)

- `null_resource.preconditions` → `terraform_data.preconditions` (drops the
  null provider; same lifecycle semantics).
- Remove the no-op `source_ranges = []` on the egress deny rule.
- `nat_dependency` plumbing switches to a `terraform_data` bridge.
- Unused data sources in `examples/gcp-byovpc/data.tf` removed.
- `bgp_best_path_selection_mode` intentionally not restored (GCP default is
  fine; noted here so the drift is on record).

---

## Phase A′ — Contract & rename

### Cross-cloud module contract (`docs/cross-cloud-module-contract.md`)

Normative document; Azure/AWS refactor PRs are reviewed against it. Sections:

1. **Module slots.** `modules/<cloud>/{network, private-connectivity, workspace,
   dns}` + composer `modules/<cloud>/databricks-workspace`; linear dependency
   `network → private-connectivity → workspace → dns`. Slots defined by
   responsibility (workspace = everything registering the workspace with the
   control plane, mws_* or ARM). Reserved slot: `serverless-connectivity` (NCC)
   — implemented on AWS/Azure; **GCP pending** (near Public Preview as of
   July 2026); interface frozen from the AWS/Azure NCC semantics
   (`serverless_private_connectivity` flag + endpoint-rule list). Shared
   cloud-neutral modules live under `modules/databricks/`.
2. **Frozen interface.** `private_link_frontend`, `private_link_backend`,
   `private_access_only`, `restricted_egress`, `serverless_egress_*` (below),
   `cmek_*` (below); `*_source ∈ {databricks_managed, create, existing}`;
   hub/spoke, frontend/backend vocabulary; `prefix`, `workspace_name`,
   `databricks_account_id`, `suffix` output.
3. **Two-tier naming rule + noun table.** Semantics frozen; native nouns per
   cloud (`vpc/vnet`, `psc/private_endpoint/vpc_endpoint`, `google_project` /
   `azure_resource_group`, `<cloud>_region`). Table maps every GCP name in this
   PR to its Azure/AWS dialect.
4. **File shape.** Modules: one-concern `.tf` files + `versions.tf`, no provider
   blocks. Examples: `versions.tf` + `providers.tf` + `main.tf` + `variables.tf`
   + `outputs.tf` + `terraform.tfvars` + `README.md` + `Makefile`. Constraint
   policy from A12.
5. **Validation & testing standard.** Cross-variable rules in
   `preconditions.tf` (`terraform_data`) with a documented rule table; positive
   fixture per scenario, negative fixture per precondition; per-submodule plan
   fixtures.

### Rename `modules/gcp/account` → `modules/gcp/workspace`

Directory, composer wiring (`module "account"` → `module "workspace"`), Makefile,
READMEs, fixtures, top-level README, PR description. Composer keeps the name
`databricks-workspace`; its README states the distinction from the `workspace`
submodule.

---

## Phase B — GCP sandbox verification

Run after Phase A merges to the branch; blockers make earlier testing pointless.

| Scenario | Checks |
|---|---|
| `examples/gcp-basic` | apply → workspace reachable → destroy |
| `examples/gcp-byovpc` | apply → workspace reachable → destroy |
| `examples/gcp-with-psc-exfiltration-protection` | apply → **launch smallest cluster and run a command** (validates A2/A3) → frontend reachable only via PSC → UC attach → destroy |

Requires user-supplied sandbox project + `gcloud auth login` in-session.
Results recorded in the PR's test-plan checklist (currently overstated; will be
corrected to reflect reality either way).

---

## Phase C — Feature additions

### C1. Serverless egress control (`workspace` submodule)

New `serverless-egress.tf`: `databricks_account_network_policy.this` (named
`<prefix>-serverless-egress-<suffix>`) + `databricks_workspace_network_option`
binding it to the workspace. Composer interface (contract-frozen, identical
resources on all clouds):

| Variable | Type / default | Meaning |
|---|---|---|
| `serverless_egress_mode` | string, `"unmanaged"` | `unmanaged` (no resources) / `full` / `restricted` |
| `serverless_allowed_internet_destinations` | list(string), `[]` | FQDNs allowed when restricted |
| `serverless_allowed_storage_destinations` | list(string), `[]` | GCS bucket names allowed when restricted (region = `google_region`) |
| `serverless_egress_enforcement` | string, `"enforced"` | `enforced` / `dry_run` |

Preconditions: destination lists require `mode="restricted"`; README notes the
Enterprise-tier requirement (not checkable from Terraform). The PSC example
enables `restricted` — closing its serverless exfiltration gap is the point.

### C2. CMEK (`workspace` submodule)

New `cmek.tf`: up to two `databricks_mws_customer_managed_keys` resources
(`MANAGED_SERVICES`, `STORAGE`) from Cloud KMS key IDs, wired into
`databricks_mws_workspaces`. Composer interface (contract-frozen concept;
key-reference type is the per-cloud noun):

- `cmek_managed_services_key_id` (string, null) — Cloud KMS key resource ID.
- `cmek_storage_key_id` (string, null).
- `cmek_grant_key_permissions` (bool, true) — when true the module creates the
  `google_kms_crypto_key_iam_member` grants (`cloudkms.cryptoKeyEncrypterDecrypter`)
  for the Databricks service agent; false for orgs where key IAM is centrally
  managed. README documents the required grants for the false path.

GA on GCP, Enterprise tier. Keys are create-time only on the workspace —
documented; no in-place update promises.

### C3. Remove GKE pod/svc CIDRs (`network` submodule)

`pod_cidr`, `svc_cidr`, and the `secondary_ip_range` block are deleted from
`network`, the composer, fixtures, examples, and docs. Rationale: the GCP data
plane is GCE; BYOVPC requires exactly one subnet and no secondary ranges.
Breaking for GKE-era configs — PR description carries a release note.

### C4. Shared security-settings module (`modules/databricks/security-settings`)

Cloud-neutral (the resources are identical on all clouds), hence the first
resident of `modules/databricks/` rather than `modules/gcp/`. Takes a
**workspace-level** databricks provider from the caller
(`providers = { databricks = databricks.workspace }`); never called by the
composer (which is account-level by design). Wired into the PSC example after
workspace creation.

| Variable | Resource |
|---|---|
| `enable_compliance_security_profile` + `compliance_standards` | `databricks_compliance_security_profile_setting` |
| `enable_enhanced_security_monitoring` | `databricks_enhanced_security_monitoring_setting` |
| `automatic_cluster_update` (object: enabled + maintenance window) | `databricks_automatic_cluster_update_setting` |
| `ip_access_lists` (list of allow/block CIDR objects, default `[]`) | `databricks_ip_access_list` |

CSP is irreversible once enabled → variable description carries the warning and
the README repeats it. CSP requires ESM implicitly; a precondition enforces
`enable_compliance_security_profile ⇒ enable_enhanced_security_monitoring`.

### C5. NCC — reserved slot only (decision flagged for review)

**Recommendation:** no GCP NCC code in this public examples repo until the
feature is at least Public Preview. The contract doc freezes the
`serverless-connectivity` slot and interface now (from AWS/Azure
`databricks_mws_network_connectivity_config` semantics), so the GCP
implementation at PuPr is a mechanical follow-up PR. Alternative considered and
rejected: pre-staged code behind a hard-off flag — dead unappliable code in an
official Databricks repo, drifting until release.

---

## Interface after this spec (composer additions/removals)

Added: `serverless_egress_mode`, `serverless_allowed_internet_destinations`,
`serverless_allowed_storage_destinations`, `serverless_egress_enforcement`,
`cmek_managed_services_key_id`, `cmek_storage_key_id`,
`cmek_grant_key_permissions`.
Removed: `pod_cidr`, `svc_cidr`.
Changed: precondition table (A4, A6); `hive_metastore_ip` description (A7).

## Migration impact

| Change | Impact |
|---|---|
| `account` → `workspace` module rename | Module addresses change; PR already mandates clean-state re-apply |
| `restricted_egress` now requires both PSC flags | Configs with one flag failed at apply/runtime before; now fail at plan with a clear message |
| `pod_cidr`/`svc_cidr` removed | GKE-era BYOVPC configs must drop the inputs; release-noted |
| PAT `token {}` removed | Consumers relying on the module-created token must create their own |
| `databricks >= 1.85` floor | Needed for network-policy resources |

## Implementation phasing

1. `fix(gcp)`: A1–A9 (correctness; one commit per blocker, majors grouped)
2. `refactor(gcp)`: A10–A13 (cleanups)
3. `refactor(gcp)`: account → workspace rename
4. `docs`: cross-cloud module contract
5. `feat(gcp/workspace)`: serverless egress control (C1)
6. `feat(gcp/workspace)`: CMEK (C2)
7. `refactor(gcp/network)`: drop GKE secondary ranges (C3)
8. `feat(databricks/security-settings)`: shared module + PSC example wiring (C4)
9. `docs`: terraform-docs regen + README refresh
10. Phase B sandbox verification (manual, results into PR test plan)

Each commit leaves the tree validating; fixtures updated in the same commit as
the behavior they cover.

## Open questions

1. C5 (NCC slot-only) is a recommendation, not a settled decision — confirm or
   ask for the pre-staged-code alternative.
