variable "databricks_account_id" {
  type        = string
  description = "Databricks Account ID"
}

variable "google_region" {
  type        = string
  description = "Google Cloud region where the resources will be created"
}

variable "workspace_google_project" {
  type        = string
  description = "Google Cloud project ID where the Databricks workspace lives"
}

variable "spoke_vpc_google_project" {
  type        = string
  description = "Google Cloud project ID hosting the spoke VPC (often the same as workspace project)"
}

variable "hub_vpc_google_project" {
  type        = string
  description = "Google Cloud project ID hosting the hub VPC"
}

variable "is_spoke_vpc_shared" {
  type        = bool
  description = "Whether the spoke VPC project hosts a Shared VPC and the workspace project is bound as a service project"
}

variable "prefix" {
  type        = string
  description = "Prefix used to name generated resources"
}

# For the value of the regional Hive Metastore IP, refer to the Databricks documentation
# https://docs.gcp.databricks.com/en/resources/ip-domain-region.html#addresses-for-default-metastore
variable "hive_metastore_ip" {
  type        = string
  description = "Regional default Hive Metastore IP (used by the spoke egress firewall to allow MySQL/3306)"
}

variable "hub_vpc_cidr" {
  type        = string
  description = "CIDR for the hub subnet"
}

variable "spoke_vpc_cidr" {
  type        = string
  description = "CIDR of the spoke VPC address space (used as source_ranges for the hub ingress firewall)"
}

variable "subnet_cidr" {
  type        = string
  description = "CIDR for the spoke subnet (must be within spoke_vpc_cidr)"
}

variable "psc_subnet_cidr" {
  type        = string
  description = "CIDR for the dedicated PSC subnet in the spoke VPC"
}

variable "metastore_name" {
  type        = string
  description = "Name to assign to regional Unity Catalog metastore"
}

variable "catalog_name" {
  type        = string
  description = "Name to assign to default Unity Catalog catalog"
}

variable "serverless_egress_mode" {
  type        = string
  default     = "restricted"
  description = "Serverless egress control mode (unmanaged, full, restricted). Default restricted: deny-by-default for serverless, matching this example's classic-compute posture. Requires Enterprise tier"
}

variable "serverless_allowed_internet_destinations" {
  type        = list(string)
  default     = []
  description = "FQDNs serverless workloads may reach (only with serverless_egress_mode=restricted)"
}

variable "serverless_allowed_storage_destinations" {
  type        = list(string)
  default     = []
  description = "GCS bucket names serverless workloads may reach (only with serverless_egress_mode=restricted)"
}

variable "serverless_egress_enforcement" {
  type        = string
  default     = "enforced"
  description = "enforced or dry_run (log-only evaluation)"
}

# === Customer-managed keys (CMEK) =======================================
variable "cmek_managed_services_key_id" {
  type        = string
  default     = null
  description = "Cloud KMS key resource ID for managed-services CMEK (control-plane data: notebooks, secrets, queries). Null disables. The principal running Terraform needs cloudkms.cryptoKeys.getIamPolicy and setIamPolicy on the key - Databricks sets the key's IAM policy at workspace creation. Enterprise tier; set at creation only"
}

variable "cmek_storage_key_id" {
  type        = string
  default     = null
  description = "Cloud KMS key resource ID for workspace-storage CMEK (GCS buckets and GCE persistent disks). Null disables. Same permission and tier requirements as cmek_managed_services_key_id; set at creation only"
}