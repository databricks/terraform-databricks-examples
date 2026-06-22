# Account
variable "databricks_account_id" {
  type        = string
  description = "Databricks Account ID"

  validation {
    condition     = can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", lower(var.databricks_account_id)))
    error_message = "databricks_account_id must be a valid UUID (e.g., 12345678-1234-1234-1234-123456789012)."
  }
}

# Region
variable "google_region" {
  type        = string
  description = "Google Cloud region where the resources will be created"

  validation {
    condition = contains([
      "asia-northeast1", "asia-south1", "asia-southeast1",
      "australia-southeast1",
      "europe-west1", "europe-west2", "europe-west3",
      "northamerica-northeast1",
      "southamerica-east1",
      "us-central1", "us-east1", "us-east4", "us-west1", "us-west4"
    ], var.google_region)
    error_message = "google_region must be a GCP region that supports Databricks PSC endpoints."
  }
}

# Projects
variable "workspace_google_project" {
  type        = string
  description = "Google Cloud project ID related to Databricks workspace"
}

variable "spoke_vpc_google_project" {
  type        = string
  description = "Google Cloud project ID related to Spoke VPC"
}

variable "hub_vpc_google_project" {
  type        = string
  description = "Google Cloud project ID related to Hub VPC"
}

# Network
variable "is_spoke_vpc_shared" {
  type        = bool
  description = "Whether the Spoke VPC is a Shared or a dedicated VPC"
}

variable "hub_vpc_cidr" {
  type        = string
  description = "CIDR for Hub VPC"

  validation {
    condition     = can(cidrhost(var.hub_vpc_cidr, 0))
    error_message = "hub_vpc_cidr must be a valid CIDR block (e.g., 10.0.0.0/24)."
  }
}

variable "spoke_vpc_cidr" {
  type        = string
  description = "CIDR for Spoke VPC"

  validation {
    condition     = can(cidrhost(var.spoke_vpc_cidr, 0))
    error_message = "spoke_vpc_cidr must be a valid CIDR block (e.g., 10.1.0.0/24)."
  }
}

variable "psc_subnet_cidr" {
  type        = string
  description = "CIDR for PSC subnet within the Spoke VPC"

  validation {
    condition     = can(cidrhost(var.psc_subnet_cidr, 0))
    error_message = "psc_subnet_cidr must be a valid CIDR block (e.g., 10.1.1.0/24)."
  }
}

# Naming
variable "prefix" {
  type        = string
  description = "Prefix to use in generated resource names"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,20}$", var.prefix))
    error_message = "prefix must start with a lowercase letter, contain only lowercase letters, numbers, and hyphens, and be 2-21 characters long."
  }
}

# For the value of the regional Hive Metastore IP, refer to the Databricks documentation
# Here - https://docs.gcp.databricks.com/en/resources/ip-domain-region.html#addresses-for-default-metastore
variable "hive_metastore_ip" {
  type        = string
  description = "IP address of the regional default Hive Metastore"

  validation {
    condition     = can(regex("^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}$", var.hive_metastore_ip))
    error_message = "hive_metastore_ip must be a valid IPv4 address."
  }
}

# Tags
variable "tags" {
  type        = map(string)
  description = "Map of tags to add to all resources"
}
