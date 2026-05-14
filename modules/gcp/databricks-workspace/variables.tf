# === Identity ===========================================================
variable "prefix" {
  type = string
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

variable "workspace_name" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}

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
variable "spoke_vpc_cidr" {
  type    = string
  default = null
}

variable "subnet_cidr" {
  type    = string
  default = null
}

variable "pod_cidr" {
  type    = string
  default = null
}

variable "svc_cidr" {
  type    = string
  default = null
}

# When vpc_source = "existing"
variable "existing_vpc_name" {
  type    = string
  default = null
}

variable "existing_subnet_name" {
  type    = string
  default = null
}

# === Connectivity feature flags =========================================
variable "private_link_frontend" {
  type    = bool
  default = false
}

variable "private_link_backend" {
  type    = bool
  default = false
}

variable "private_access_only" {
  type    = bool
  default = false
}

variable "restricted_egress" {
  type    = bool
  default = false
}

# === Required when restricted_egress = true =============================
variable "hub_vpc_google_project" {
  type    = string
  default = null
}

variable "spoke_vpc_google_project" {
  type    = string
  default = null
}

variable "is_spoke_vpc_shared" {
  type    = bool
  default = false
}

variable "hub_vpc_cidr" {
  type    = string
  default = null
}

variable "psc_subnet_cidr" {
  type    = string
  default = null
}

variable "hive_metastore_ip" {
  type    = string
  default = null
}
