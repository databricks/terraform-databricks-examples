variable "prefix" {
  type = string
}

variable "google_region" {
  type = string
}

# Hub
variable "hub_vpc_id" {
  type = string
}

variable "hub_vpc_self_link" {
  type = string
}

variable "hub_vpc_google_project" {
  type = string
}

# Spoke
variable "spoke_vpc_id" {
  type = string
}

variable "spoke_vpc_self_link" {
  type = string
}

variable "spoke_vpc_google_project" {
  type = string
}

# Workspace
variable "workspace_url" {
  type = string
}

# PSC IPs
variable "frontend_psc_ip_spoke" {
  type = string
}

variable "frontend_psc_ip_hub" {
  type    = string
  default = null
}

variable "backend_psc_ip_spoke" {
  type = string
}
