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
  description = "GCP project hosting the existing VPC and subnet (also the workspace project)"
}

variable "google_region" {
  type        = string
  description = "GCP region for workspace deployment (must match the existing subnet's region)"
}

variable "google_zone" {
  type        = string
  description = "GCP zone (used by the google provider)"
}

variable "prefix" {
  type        = string
  description = "Prefix used to name Databricks-side resources (mws_networks, mws_workspaces)"
}

variable "workspace_name" {
  type        = string
  description = "Workspace name"
}

variable "existing_vpc_name" {
  type        = string
  description = "Name of the pre-existing GCP VPC to deploy the workspace into"
}

variable "existing_subnet_name" {
  type        = string
  description = "Name of the pre-existing subnet inside the VPC (must be in google_region)"
}
