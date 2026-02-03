variable "workspace_host" {
  type = string
}

variable "cluster-policies" {
  type = map(object({
    team = string
    environment = string
    policy_version = string
    policy_key = string
    policy_family_id = string
    policy_overrides = optional(string, "{}")
    group_assignments = list(string)
    service_principal_assignments = list(string)
  }))
  default = {}
}