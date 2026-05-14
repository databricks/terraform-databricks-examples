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
  description = "Override for spoke subnet name (default: \"{prefix}-subnet-{suffix}\")"
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
