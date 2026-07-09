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

# === Hub configuration (only when enable_hub = true) =====================
variable "enable_hub" {
  type        = bool
  default     = false
  description = "Enable the hub half of the topology: hub VPC/subnet (created or looked up per hub_vpc_source) and hub-spoke peering. Composer passes restricted_egress"
}

variable "enable_hub_spoke_peering" {
  type        = bool
  default     = true
  description = "Create the bidirectional VPC peering between hub and spoke. Disable when hub-spoke connectivity is provided by other means (e.g. Shared VPC or an existing transit). Cloud DNS peering zones do not depend on it. Only takes effect when the hub is enabled"
}

variable "hub_vpc_source" {
  type        = string
  default     = "create"
  description = "Where the hub VPC comes from when the hub is enabled. create: Terraform creates the hub VPC and subnet (hub_vpc_cidr required); existing: data-source lookup of existing_hub_vpc_name/existing_hub_subnet_name in hub_vpc_google_project"
  validation {
    condition     = contains(["create", "existing"], var.hub_vpc_source)
    error_message = "hub_vpc_source must be 'create' or 'existing'."
  }
}

variable "existing_hub_vpc_name" {
  type        = string
  default     = null
  description = "Name of the pre-existing hub VPC. Required when hub_vpc_source=existing"
}

variable "existing_hub_subnet_name" {
  type        = string
  default     = null
  description = "Name of the pre-existing hub subnet (must be in google_region). Required when hub_vpc_source=existing"
}

variable "hub_vpc_google_project" {
  type        = string
  default     = null
  description = "GCP project hosting the hub VPC (required when enable_hub=true)"
}

variable "hub_vpc_cidr" {
  type        = string
  default     = null
  description = "CIDR for the hub subnet (required when enable_hub=true)"
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

variable "enable_nat" {
  type        = bool
  default     = true
  description = "Create Cloud Router + NAT for internet egress. The composer disables this under restricted_egress, where no internet egress path may exist"
}
