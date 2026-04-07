variable "team" {
  description = "line of business that owns the workloads"
  type = string
}

variable "environment" {
  description = "development environment policy belongs to"
  type = string

  validation {
    condition = contains(["dev", "prod"], var.environment)
    error_message = "Valid values are (dev, prod)."
  }
}

variable "policy_version" {
  description = "Cluster policy version (e.g. 0.0.1)"
  type = string
}

variable "policy_key" {
  description = "Used to lookup default JSON configuration.  Similar to policy_family_id, but allows for additional configurations not supported by policy families, such as Spark Declarative Pipelines (sdp)"
  type = string

  validation {
    condition = contains(["personal-vm", "shared-compute", "power-user", "job-cluster", "sdp-cluster"], var.policy_key)
    error_message = "Policy key must be one of the following (personal-vm, shared-compute, power-user, job-cluster, sdp-cluster)"
  }
}

variable "policy_family_id" {
  description = "Id of policy family"
  type = string

  validation {
    condition = contains(["personal-vm", "shared-compute", "power-user", "job-cluster"], var.policy_family_id)
    error_message = "Policy Id must be one of the following (personal-vm, shared-compute, power-user, job-cluster)"
  }
}

variable "policy_overrides" {
  description = "Cluster policy overrides"
  type        = string
  default     = "{}"
}

variable "group_assignments" {
  description = "Groups to assign to use cluster policy"
  type = list(string)
  default = []
}

variable "service_principal_assignments" {
  description = "Service Principals to assign to cluster policy"
  type = list(string)
  default = []
}

variable "user_assignments" {
  description = "Users to assign to use cluster policy"
  type = list(string)
  default = []
}