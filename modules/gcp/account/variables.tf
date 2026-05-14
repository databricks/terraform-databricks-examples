variable "prefix" {
  type = string
}

variable "suffix" {
  type = string
}

variable "workspace_name" {
  type    = string
  default = null
}

variable "databricks_account_id" {
  type = string
}

variable "google_project" {
  type = string
}

variable "google_region" {
  type = string
}

variable "vpc_source" {
  type = string
  validation {
    condition     = contains(["databricks_managed", "create", "existing"], var.vpc_source)
    error_message = "vpc_source must be one of: databricks_managed, create, existing."
  }
}

variable "spoke_vpc_name" {
  type    = string
  default = null
}

variable "spoke_subnet_name" {
  type    = string
  default = null
}

variable "spoke_vpc_google_project" {
  type    = string
  default = null
}

variable "hub_vpc_google_project" {
  type    = string
  default = null
}

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

variable "enable_frontend" {
  type    = bool
  default = false
}

variable "enable_backend" {
  type    = bool
  default = false
}

variable "private_access_only" {
  type    = bool
  default = false
}

variable "nat_dependency" {
  type        = any
  default     = null
  description = "Opaque value used as depends_on for the workspace to ensure NAT readiness"
}
