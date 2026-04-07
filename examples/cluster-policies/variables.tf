variable "workspace_host" {
  description = "URL of the workspace to execute this module against"
  type = string
}

variable "cluster_policies" {
  description = "Convenience variable that bundles all required variables for cluster-policy-from-policy-family module.  Each object in the map represents one policy to create."  
  type = map(object({
    team = string
    environment = string
    policy_version = string
    policy_key = string
    policy_family_id = string
    policy_overrides = optional(string, "{}")
    group_assignments = optional(list(string), [])
    service_principal_assignments = optional(list(string), [])
    user_assignments = optional(list(string), [])
  }))
  default = {}
}