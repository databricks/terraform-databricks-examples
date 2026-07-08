variable "enable_compliance_security_profile" {
  type        = bool
  default     = false
  description = "Enable the Compliance Security Profile on the workspace. WARNING: irreversible - CSP cannot be disabled once enabled. Requires enable_enhanced_security_monitoring=true"
}

variable "compliance_standards" {
  type        = list(string)
  default     = []
  description = "Compliance standards for the CSP (e.g. [\"HIPAA\"]). Only meaningful when enable_compliance_security_profile=true"
}

variable "enable_enhanced_security_monitoring" {
  type        = bool
  default     = false
  description = "Enable Enhanced Security Monitoring (hardened images, monitoring agents)"
}

variable "enable_automatic_cluster_update" {
  type        = bool
  default     = false
  description = "Enable automatic cluster update for the workspace"
}

variable "ip_access_lists" {
  type = list(object({
    label        = string
    list_type    = string
    ip_addresses = list(string)
  }))
  default     = []
  description = "Workspace IP access lists. list_type is ALLOW or BLOCK. A non-empty list also flips the enableIpAccessLists workspace conf"
  validation {
    condition     = alltrue([for l in var.ip_access_lists : contains(["ALLOW", "BLOCK"], l.list_type)])
    error_message = "ip_access_lists[*].list_type must be ALLOW or BLOCK."
  }
}
