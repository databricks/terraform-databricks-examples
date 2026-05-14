variable "prefix"        { type = string }
variable "suffix"        { type = string }
variable "google_region" { type = string }

# Spoke network refs
variable "spoke_vpc_id"             { type = string }
variable "spoke_vpc_self_link"      { type = string }
variable "spoke_vpc_google_project" { type = string }
variable "spoke_vpc_cidr"           { type = string }

# Hub network refs (nullable when no hub)
variable "hub_vpc_id" {
  type    = string
  default = null
}
variable "hub_vpc_self_link" {
  type    = string
  default = null
}
variable "hub_vpc_google_project" {
  type    = string
  default = null
}
variable "hub_subnet_name" {
  type    = string
  default = null
}
variable "hub_vpc_cidr" {
  type    = string
  default = null
}

# Feature flags
variable "enable_frontend" {
  type    = bool
  default = false
}
variable "enable_backend" {
  type    = bool
  default = false
}
variable "restrict_egress" {
  type    = bool
  default = false
}

# PSC subnet CIDR
variable "psc_subnet_cidr" {
  type        = string
  description = "CIDR for the dedicated PSC subnet in the spoke VPC"
}

variable "hive_metastore_ip" {
  type        = string
  default     = null
  description = "Regional Hive metastore IP (looked up via internal map if null)"
}
