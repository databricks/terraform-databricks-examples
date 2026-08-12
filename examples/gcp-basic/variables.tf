variable "databricks_account_id" {
  type        = string
  description = "Databricks Account ID"
}

variable "databricks_google_service_account" {
  type        = string
  description = "Service account email used for Databricks provider authentication"
}

variable "google_project" {
  type        = string
  description = "GCP project where the workspace will be created"
}

variable "google_region" {
  type        = string
  description = "GCP region for workspace deployment"
}

variable "google_zone" {
  type        = string
  description = "GCP zone (used by the google provider)"
}

variable "prefix" {
  type        = string
  description = "Prefix used to name generated resources"
}

variable "workspace_name" {
  type        = string
  description = "Workspace name"
}

