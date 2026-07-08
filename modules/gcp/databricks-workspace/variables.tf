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
  description = "If true and the spoke VPC project differs from the workspace project, bind the spoke project as a Shared-VPC host and the workspace project as a service project. Works with or without restricted_egress"
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
  description = "Regional legacy Hive metastore IP. When set, an egress allow rule (tcp/3306) is created under restricted egress; when null, no rule is created. Workspaces using Unity Catalog (the default) do not need this. Regional IPs: https://docs.databricks.com/gcp/en/resources/ip-domain-region"
}
