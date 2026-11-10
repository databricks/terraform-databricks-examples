variable "databricks_account_id" {
  description = "Databricks account ID."
  type        = string
}

variable "network_connectivity_config_id" {
  description = "ID of the network connectivity configuration (NCC) that owns the gateway. The NCC must be in the same region as the gateway subnet."
  type        = string
}

variable "location" {
  description = "Azure region of the VNet and NCC. Must be a region where private network gateway is available."
  type        = string

  validation {
    # Public Preview regions, from
    # https://learn.microsoft.com/azure/databricks/security/network/serverless-network-security/private-network-gateway/configure-private-network-gateway
    condition = contains([
      "australiaeast", "brazilsouth", "canadacentral", "centralindia", "centralus",
      "eastasia", "eastus", "eastus2", "francecentral", "germanywestcentral",
      "japaneast", "koreacentral", "northcentralus", "northeurope", "southcentralus",
      "southeastasia", "swedencentral", "switzerlandnorth", "uaenorth", "uksouth",
      "westcentralus", "westeurope", "westus", "westus2", "westus3",
    ], var.location)
    error_message = "Private network gateway is not available in this region during Public Preview. Supported regions: australiaeast, brazilsouth, canadacentral, centralindia, centralus, eastasia, eastus, eastus2, francecentral, germanywestcentral, japaneast, koreacentral, northcentralus, northeurope, southcentralus, southeastasia, swedencentral, switzerlandnorth, uaenorth, uksouth, westcentralus, westeurope, westus, westus2, westus3."
  }
}

variable "resource_group_name" {
  description = "Resource group of the VNet that gets the gateway subnet."
  type        = string
}

variable "virtual_network_name" {
  description = "Name of the existing VNet that gets the gateway subnet."
  type        = string
}

variable "gateway_subnet_name" {
  description = "Name of the dedicated gateway subnet created by this module."
  type        = string
  default     = "private-network-gateway"

  validation {
    condition     = can(regex("^[A-Za-z0-9]([A-Za-z0-9_.-]{0,78}[A-Za-z0-9_])?$", var.gateway_subnet_name))
    error_message = "gateway_subnet_name must be 1-80 characters of letters, digits, '_', '.' or '-', start with a letter or digit, and end with a letter, digit or '_'."
  }
}

variable "gateway_subnet_address_prefix" {
  description = "IPv4 CIDR of the gateway subnet, for example 10.0.1.0/28. Must be /28 or larger, inside the VNet address space and unused."
  type        = string

  validation {
    condition = (
      can(cidrnetmask(var.gateway_subnet_address_prefix))
      && try(cidrsubnet(var.gateway_subnet_address_prefix, 0, 0) == var.gateway_subnet_address_prefix, false)
      && try(tonumber(split("/", var.gateway_subnet_address_prefix)[1]) <= 28, false)
    )
    error_message = "gateway_subnet_address_prefix must be an IPv4 network address in CIDR notation with a prefix length of 28 or less (a /28 or larger), for example 10.0.1.0/28."
  }
}

variable "display_name" {
  description = "Display name of the private network gateway."
  type        = string

  validation {
    condition     = length(trimspace(var.display_name)) > 0
    error_message = "display_name must not be empty."
  }
}

variable "traffic_mode" {
  description = "SPECIFIC_DESTINATIONS routes only the listed DNS names through the gateway. ALL_TRAFFIC routes all remaining serverless egress through the gateway."
  type        = string
  default     = "SPECIFIC_DESTINATIONS"

  validation {
    condition     = contains(["SPECIFIC_DESTINATIONS", "ALL_TRAFFIC"], var.traffic_mode)
    error_message = "traffic_mode must be SPECIFIC_DESTINATIONS or ALL_TRAFFIC."
  }
}

variable "destinations" {
  description = "DNS names routed through the gateway in SPECIFIC_DESTINATIONS mode (1-100). Suffix matching applies: mydb.contoso.com also matches sub.mydb.contoso.com. Must be empty for ALL_TRAFFIC."
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.destinations) <= 100
    error_message = "A gateway supports at most 100 destinations."
  }

  validation {
    condition = alltrue([
      for d in var.destinations : can(regex("^([a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?\\.)+[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$", d))
    ])
    error_message = "destinations must be lowercase DNS names without scheme, port, path or wildcard."
  }

  validation {
    # The API rejects these with "The following destinations are reserved and
    # cannot be used as PNG destinations". The suffix check also covers the
    # privatelink.* forms, for example privatelink.blob.core.windows.net.
    condition = alltrue(flatten([
      for d in var.destinations : [
        for s in [
          "blob.core.windows.net", "dfs.core.windows.net", "queue.core.windows.net",
          "table.core.windows.net", "file.core.windows.net", "web.core.windows.net",
          "vault.azure.net", "vaultcore.azure.net", "servicebus.windows.net",
        ] : !(d == s || endswith(d, ".${s}"))
      ]
    ]))
    error_message = "destinations contain a reserved Azure service name (*.blob, *.dfs, *.queue, *.table, *.file or *.web.core.windows.net, *.vault.azure.net, *.vaultcore.azure.net, *.servicebus.windows.net, or their privatelink.* forms). The API rejects these. Use NCC private endpoint rules (databricks_mws_ncc_private_endpoint_rule) for these services."
  }
}

variable "private_dns_resolvers" {
  description = "Custom DNS resolver IPv4 addresses reachable from the gateway subnet (at most 2). Leave empty to use Azure-provided DNS, which is the recommended setting."
  type        = list(string)
  default     = []

  validation {
    condition = length(var.private_dns_resolvers) <= 2 && alltrue([
      for ip in var.private_dns_resolvers : can(regex("^((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\\.){3}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$", ip))
    ])
    error_message = "private_dns_resolvers accepts at most 2 IPv4 addresses."
  }

  validation {
    condition     = !contains(var.private_dns_resolvers, "168.63.129.16")
    error_message = "private_dns_resolvers must not contain the Azure-provided DNS address 168.63.129.16 (the API rejects it). Leave the list empty to use Azure-provided DNS."
  }
}

variable "bandwidth_tier_gbps" {
  description = "Provisioned gateway bandwidth tier in Gbps: 10, 30, 50 or 100."
  type        = number
  default     = 10

  validation {
    condition     = contains([10, 30, 50, 100], var.bandwidth_tier_gbps)
    error_message = "bandwidth_tier_gbps must be one of 10, 30, 50 or 100."
  }
}

variable "attach_nat_gateway" {
  description = "Associate nat_gateway_id with the gateway subnet. Needed for internet-bound traffic in ALL_TRAFFIC mode unless another egress path (for example a firewall route) exists."
  type        = bool
  default     = false
}

variable "nat_gateway_id" {
  description = "Resource ID of the NAT gateway to associate with the gateway subnet. Required when attach_nat_gateway is true."
  type        = string
  default     = null
}

variable "gateway_destroy_wait" {
  description = "How long to wait on destroy after the gateway is deleted, before deleting the subnet and NAT association and releasing the NCC. Gateway cleanup continues after the delete call returns, and the subnet and NCC cannot be deleted until it finishes. Duration string, for example 30m."
  type        = string
  default     = "30m"

  validation {
    condition     = can(regex("^([0-9]+h)?([0-9]+m)?([0-9]+s)?$", var.gateway_destroy_wait)) && var.gateway_destroy_wait != ""
    error_message = "gateway_destroy_wait must be a duration such as 30s, 20m or 1h."
  }
}
