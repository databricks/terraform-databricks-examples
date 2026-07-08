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

variable "hub_vpc_google_project" {
  type        = string
  description = "GCP project hosting the hub VPC (used for the hub DNS zones)"
}

# Spoke
variable "spoke_vpc_id" {
  type        = string
  description = "ID of the spoke VPC (DNS zone with this VPC's visibility)"
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
