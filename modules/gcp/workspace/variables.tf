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
  description = "Optional workspace name override. Defaults to \"prefix-ws-suffix\" when null"
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
  description = "Name of the frontend PSC forwarding rule from private-connectivity; used as gcp_vpc_endpoint_info.psc_endpoint_name"
}

variable "backend_forwarding_rule_name" {
  type        = string
  default     = null
  description = "Name of the backend (SCC) PSC forwarding rule from private-connectivity; used as gcp_vpc_endpoint_info.psc_endpoint_name"
}

variable "hub_frontend_forwarding_rule_name" {
  type        = string
  default     = null
  description = "Name of the hub-side frontend PSC forwarding rule from private-connectivity; used as gcp_vpc_endpoint_info.psc_endpoint_name"
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

variable "create_hub" {
  type        = bool
  default     = false
  description = "Whether a hub VPC exists (composer passes restricted_egress). Gates the transit mws_vpc_endpoint; must be plan-time static"
}

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
  description = "Cloud KMS key resource ID for managed-services CMEK (control-plane data: notebooks, secrets, queries). Null disables. The principal running Terraform needs cloudkms.cryptoKeys.getIamPolicy and setIamPolicy on the key - Databricks sets the key's IAM policy at workspace creation. Enterprise tier; set at creation only"
}

variable "cmek_storage_key_id" {
  type        = string
  default     = null
  description = "Cloud KMS key resource ID for workspace-storage CMEK (GCS buckets and GCE persistent disks). Null disables. Same permission and tier requirements as cmek_managed_services_key_id; set at creation only"
}
