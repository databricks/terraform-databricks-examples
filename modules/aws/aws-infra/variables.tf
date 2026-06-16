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

variable "storage_encryption" {
  description = "S3 bucket encryption configuration. Use 'SSE-S3' for AWS-managed keys or 'SSE-KMS' for KMS-managed keys."
  type = object({
    type       = optional(string, "SSE-S3")
    kms_key_id = optional(string, null)
  })
  default = {}

  validation {
    condition     = contains(["SSE-S3", "SSE-KMS"], var.storage_encryption.type)
    error_message = "storage_encryption.type must be either 'SSE-S3' or 'SSE-KMS'."
  }

  validation {
    condition     = var.storage_encryption.type != "SSE-KMS" || var.storage_encryption.kms_key_id != null
    error_message = "storage_encryption.kms_key_id must be set when using SSE-KMS encryption."
  }
}

# IAM Configuration - Split into individual variables

# Instance Profiles (Optional)
variable "create_instance_profiles" {
  description = "Create IAM instance profiles for Databricks clusters"
  type        = bool
  default     = false
}

variable "databricks_account_id" {
  description = "Databricks Account ID (UUID). Found at accounts.cloud.databricks.com → top-right menu. Used to scope the cross-account IAM role trust policy to your Databricks account only."
  type        = string
}

variable "external_id" {
  description = "External ID for Unity Catalog IAM role trust relationship. When null, a basic trust policy (no ExternalId condition) is used. Set and re-apply once available."
  type        = string
  default     = null
}

# Additional IAM Permissions
variable "roles_to_assume" {
  description = "Additional IAM role ARNs that the cross-account role should be able to assume"
  type        = list(string)
  default     = []
}

variable "cross_account_policy_type" {
  description = "Databricks cross-account IAM policy type. Options: 'managed' (default AWS-managed policy), 'restricted' (least-privilege), 'customer-managed' (customer-managed VPC)"
  type        = string
  default     = "managed"

  validation {
    condition     = contains(["managed", "restricted", "customer-managed"], var.cross_account_policy_type)
    error_message = "cross_account_policy_type must be one of: managed, restricted, customer-managed."
  }
}

# Security Configuration  
variable "security" {
  description = "Advanced security configuration"
  type = object({
    # Firewall configuration
    enable_network_firewall = optional(bool, false)
    allowed_fqdns           = optional(list(string), [])
    allowed_network_rules = optional(list(object({
      protocol         = string
      source_ip        = string
      destination_ip   = string
      destination_port = string
    })), [])

    # Private Link configuration
    enable_private_link  = optional(bool, false)
    backend_service_name = optional(string, null)
    relay_service_name   = optional(string, null)
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

    enable_dns_support = optional(bool, true)
  })

  default = {}

  validation {
    condition     = !var.advanced_networking.hub_spoke_architecture || var.advanced_networking.enable_transit_gateway
    error_message = "Transit Gateway must be enabled when using hub-spoke architecture."
  }
}

