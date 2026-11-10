variable "azure_subscription_id" {
  description = "Azure subscription ID for the resource group, VNet and NAT gateway."
  type        = string
}

variable "azure_tenant_id" {
  description = "Microsoft Entra ID tenant ID used by the Databricks provider with azure-cli auth. null uses the Azure CLI default tenant."
  type        = string
  default     = null
}

variable "databricks_account_id" {
  description = "Databricks account ID (shown in the account console)."
  type        = string
}

variable "databricks_auth_type" {
  description = "Auth type for the account-level Databricks provider, for example azure-cli or oauth-m2m."
  type        = string
  default     = "azure-cli"
}

variable "prefix" {
  description = "Prefix for resource names."
  type        = string
  default     = "png-example"
}

variable "location" {
  description = "Azure region. Must support private network gateway during Public Preview."
  type        = string
  default     = "eastus2"
}

variable "vnet_address_space" {
  description = "Address space of the VNet created by this example."
  type        = string
  default     = "10.0.0.0/24"
}

variable "gateway_subnet_address_prefix" {
  description = "CIDR of the gateway subnet (/28 or larger, inside vnet_address_space)."
  type        = string
  default     = "10.0.0.0/28"
}

variable "traffic_mode" {
  description = "SPECIFIC_DESTINATIONS or ALL_TRAFFIC."
  type        = string
  default     = "SPECIFIC_DESTINATIONS"
}

variable "destinations" {
  description = "DNS names routed through the gateway in SPECIFIC_DESTINATIONS mode. Must be empty for ALL_TRAFFIC."
  type        = list(string)
  default     = []
}

variable "private_dns_resolvers" {
  description = "Custom DNS resolver IPs reachable from the gateway subnet (at most 2). Empty uses Azure-provided DNS."
  type        = list(string)
  default     = []
}

variable "bandwidth_tier_gbps" {
  description = "Gateway bandwidth tier in Gbps: 10, 30, 50 or 100."
  type        = number
  default     = 10
}

variable "attach_nat_gateway" {
  description = "Associate the example NAT gateway with the gateway subnet. Gives internet-bound gateway traffic a static egress IP."
  type        = bool
  default     = true
}

variable "private_dns_zone_ids" {
  description = "Resource IDs of existing private DNS zones to link to the VNet, so the gateway can resolve names in them."
  type        = list(string)
  default     = []
}

variable "workspace_id" {
  description = "Optional workspace ID to bind to the NCC. null creates no binding. The workspace must be in the same region. Binding replaces any NCC already attached to the workspace."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to Azure resources."
  type        = map(string)
  default     = {}
}
