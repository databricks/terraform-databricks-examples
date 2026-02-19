# Core Configuration Variables
variable "prefix" {
  description = "Prefix for all AWS resources"
  type        = string
}

variable "region" {
  description = "AWS region for resource deployment"
  type        = string
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

# Networking Configuration
variable "networking" {
  description = "VPC and networking configuration"
  type = object({
    vpc_cidr             = string
    availability_zones   = optional(list(string), [])
    enable_nat_gateway   = optional(bool, true)
    private_subnet_cidrs = optional(list(string), [])
    public_subnet_cidrs  = optional(list(string), [])
  })
}

# Storage Configuration - Individual Variables
variable "create_metastore_bucket" {
  description = "Create Unity Catalog metastore bucket"
  type        = bool
  default     = false
}

# IAM Configuration - Split into individual variables

# Instance Profiles (Optional)
variable "create_instance_profiles" {
  description = "Create IAM instance profiles for Databricks clusters"
  type        = bool
  default     = false
}

# Cross-Account Configuration (Always created)
variable "databricks_account_id" {
  description = "Databricks AWS account ID for cross-account role trust relationship"
  type        = string
  default     = null
}

variable "external_id" {
  description = "External ID for Unity Catalog role trust relationship"
  type        = string
  default     = null
}

# Unity Catalog Configuration (Always created)
variable "unity_catalog_account_id" {
  description = "Unity Catalog AWS account ID (Databricks account for Unity Catalog)"
  type        = string
  default     = null
}

# Additional IAM Permissions
variable "roles_to_assume" {
  description = "Additional IAM role ARNs that the cross-account role should be able to assume"
  type        = list(string)
  default     = []
}

# Security Configuration  
variable "security" {
  description = "Advanced security configuration"
  type = object({
    # Firewall configuration
    enable_network_firewall = optional(bool, false)
    allowed_fqdns = optional(list(string), [])
    allowed_network_rules = optional(list(object({
      protocol         = string
      source_ip        = string
      destination_ip   = string
      destination_port = string
    })), [])

    # Private Link configuration
    enable_private_link     = optional(bool, false)
    backend_service_name    = optional(string, null)
    relay_service_name      = optional(string, null)
  })

  default = {}
}

# Advanced Networking Configuration
variable "advanced_networking" {
  description = "Advanced networking features"
  type = object({
    # Transit Gateway
    enable_transit_gateway = optional(bool, false)
    hub_spoke_architecture = optional(bool, false)

    # Hub VPC configuration (when hub-spoke enabled)
    hub_vpc_cidr = optional(string, "10.1.0.0/16")

    # Additional VPC attachments
    additional_vpc_attachments = optional(list(object({
      vpc_id     = string
      vpc_cidr   = string
      route_cidr = string
      subnet_ids = list(string)
    })), [])

    # Routing configuration
    propagate_default_routes = optional(bool, false)
    enable_dns_support       = optional(bool, true)
  })

  default = {}

  validation {
    condition     = !var.advanced_networking.hub_spoke_architecture || var.advanced_networking.enable_transit_gateway
    error_message = "Transit Gateway must be enabled when using hub-spoke architecture."
  }
}

# Data Sources Configuration
variable "databricks_config" {
  description = "Databricks-specific configuration for policy generation"
  type = object({
    account_id = optional(string, null)
    # This helps generate proper Databricks policies but doesn't create Databricks resources
  })

  default = {}
}
