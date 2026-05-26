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
  validation {
    condition = contains([
      "asia-northeast1", "asia-south1", "asia-southeast1", "australia-southeast1",
      "europe-west1", "europe-west2", "europe-west3", "northamerica-northeast1",
      "southamerica-east1", "us-central1", "us-east1", "us-east4", "us-west1", "us-west4"
    ], var.google_region)
    error_message = "google_region must be one of the regions in the regional PSC service-attachment maps. See locals.tf in modules/gcp/private-connectivity."
  }
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
