variable "databricks_account_id" {
  type        = string
  description = "Databricks Account ID"
}

variable "google_project" {
  type        = string
  description = "Google project for VCP/workspace deployment"
}

variable "google_region" {
  type        = string
  description = "Google region for VCP/workspace deployment"
}

variable "prefix" {
  type        = string
  description = "Prefix to use in generated VPC name"
}

variable "workspace_name" {
  type        = string
  description = "Name of the workspace to create"
}

variable "delegate_from" {
  description = "Identities to allow to impersonate created service account (in form of user:user.name@example.com, group:deployers@example.com or serviceAccount:sa1@project.iam.gserviceaccount.com)"
  type        = list(string)
}
