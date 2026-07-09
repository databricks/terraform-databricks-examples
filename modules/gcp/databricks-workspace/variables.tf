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
  description = "Optional workspace name override. Defaults to \"prefix-ws-suffix\" when null"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Map of tags. Currently not propagated to child resources; reserved for future use"
}

# === VPC source ==========================================================
variable "vpc_source" {
  type = object({
    spoke = optional(string, "databricks_managed")
    hub   = optional(string)
  })
  default     = {}
  description = "Where the workspace networks come from. spoke: databricks_managed (no networking module called), create (Terraform creates VPC + subnet + NAT), existing (data-source lookup of existing_vpc_name/existing_subnet_name). hub — only relevant when spoke is create or existing, and only consumed when restricted_egress=true: create (hub VPC + subnet created; hub_vpc_cidr required; the default when unset) or existing (lookup of existing_hub_vpc_name/existing_hub_subnet_name)"
  validation {
    condition     = contains(["databricks_managed", "create", "existing"], var.vpc_source.spoke)
    error_message = "vpc_source.spoke must be one of: databricks_managed, create, existing."
  }
  validation {
    condition     = var.vpc_source.hub == null || contains(["create", "existing"], var.vpc_source.hub)
    error_message = "vpc_source.hub must be 'create' or 'existing' (or unset)."
  }
  validation {
    condition     = var.vpc_source.hub == null || contains(["create", "existing"], var.vpc_source.spoke)
    error_message = "vpc_source.hub is only relevant when vpc_source.spoke is create or existing."
  }
}

# When vpc_source.spoke = "create"
variable "spoke_vpc_cidr" {
  type        = string
  default     = null
  description = "CIDR of the spoke VPC address space (e.g. 10.0.0.0/16). Required when vpc_source.spoke=create; ignored otherwise"
}

variable "subnet_cidr" {
  type        = string
  default     = null
  description = "CIDR of the spoke subnet primary range (e.g. 10.0.0.0/22). Required when vpc_source.spoke=create"
}

# When vpc_source.spoke = "existing"
variable "existing_vpc_name" {
  type        = string
  default     = null
  description = "Name of the pre-existing VPC to use. Required when vpc_source.spoke=existing"
}

variable "existing_subnet_name" {
  type        = string
  default     = null
  description = "Name of the pre-existing subnet to use (must be in google_region). Required when vpc_source.spoke=existing"
}

# === Connectivity feature flags ==========================================
variable "private_link_frontend" {
  type        = bool
  default     = false
  description = "Create the frontend (workspace UI/API) PSC endpoint and a frontend databricks_mws_vpc_endpoint. On GCP both flags must be enabled together (see preconditions.tf)"
}

variable "private_link_backend" {
  type        = bool
  default     = false
  description = "Create the backend (SCC, data plane) PSC endpoint and a backend databricks_mws_vpc_endpoint. On GCP both flags must be enabled together (see preconditions.tf)"
}

variable "private_access_only" {
  type        = bool
  default     = false
  description = "Create databricks_mws_private_access_settings with public_access_enabled=false. Workspace becomes reachable only through PSC endpoints"
}

variable "restricted_egress" {
  type        = bool
  default     = false
  description = "Create hub VPC + bidirectional peering + deny-egress firewall + private DNS zones. Requires vpc_source.spoke=create and at least one private_link_* flag"
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
  description = "If true and the spoke VPC project differs from the workspace project, bind the spoke project as a Shared-VPC host and the workspace project as a service project. Works with or without restricted_egress"
}

variable "hub_vpc_cidr" {
  type        = string
  default     = null
  description = "CIDR of the hub subnet (e.g. 10.1.0.0/24). Required when restricted_egress=true and vpc_source.hub=create"
}

variable "enable_hub_spoke_peering" {
  type        = bool
  default     = true
  description = "Create the bidirectional VPC peering between hub and spoke. Disable when hub-spoke connectivity is provided by other means (e.g. Shared VPC or an existing transit). Cloud DNS peering zones do not depend on it. Only takes effect when the hub is enabled"
}

variable "existing_hub_vpc_name" {
  type        = string
  default     = null
  description = "Name of the pre-existing hub VPC. Required when vpc_source.hub=existing"
}

variable "existing_hub_subnet_name" {
  type        = string
  default     = null
  description = "Name of the pre-existing hub subnet (must be in google_region). Required when vpc_source.hub=existing"
}

variable "psc_subnet_cidr" {
  type        = string
  default     = null
  description = "CIDR of the dedicated PSC subnet in the spoke VPC (e.g. 10.0.255.0/28). Required when restricted_egress=true or any private_link_* flag is true"
}

variable "hive_metastore_ip" {
  type        = string
  default     = null
  description = "Regional legacy Hive metastore IP. When set, an egress allow rule (tcp/3306) is created under restricted egress; when null, no rule is created. Workspaces using Unity Catalog (the default) do not need this. Regional IPs: https://docs.databricks.com/gcp/en/resources/ip-domain-region"
  validation {
    condition     = var.hive_metastore_ip == null || can(cidrnetmask("${var.hive_metastore_ip}/32"))
    error_message = "hive_metastore_ip must be a valid IPv4 address, or null to skip the rule."
  }
}

# === Serverless egress control ===========================================
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

# === Customer-managed keys (CMEK) =======================================
variable "cmek_managed_services_key_id" {
  type        = string
  default     = null
  description = "Cloud KMS key resource ID for managed-services CMEK (control-plane data: notebooks, secrets, queries). Null disables. The principal running Terraform needs cloudkms.cryptoKeys.getIamPolicy and setIamPolicy on the key - Databricks sets the key's IAM policy at workspace creation. Enterprise tier; set at creation only. The key must exist before plan (a key created in the same configuration makes the count unknown and fails plan)"
}

variable "cmek_storage_key_id" {
  type        = string
  default     = null
  description = "Cloud KMS key resource ID for workspace-storage CMEK (GCS buckets and GCE persistent disks). Null disables. Same permission and tier requirements as cmek_managed_services_key_id; set at creation only. The key must exist before plan (a key created in the same configuration makes the count unknown and fails plan)"
}
