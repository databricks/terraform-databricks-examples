variable "databricks_account_id" {
  type        = string
  description = "Databricks Account ID"
}

variable "databricks_google_service_account" {
  description = "Email of the service account used for deployment"
  type        = string
}

variable "google_project" {
  type        = string
  description = "Google project for VCP/workspace deployment"
}

variable "google_region" {
  type        = string
  description = "Google region for VCP/workspace deployment"
}

variable "google_zone" {
  description = "Zone in GCP region"
  type        = string
}

variable "prefix" {
  type        = string
  description = "Prefix to use in generated VPC name"
}

variable "subnet_ip_cidr_range" {
  type        = string
  description = "IP Range for Nodes subnet (primary)"
}

variable "pod_ip_cidr_range" {
  type        = string
  description = "IP Range for Pods subnet (secondary)"
}

variable "svc_ip_cidr_range" {
  type        = string
  description = "IP Range for Services subnet (secondary)"
}

variable "subnet_name" {
  type        = string
  description = "Name of the subnet to create"
}

variable "router_name" {
  type        = string
  description = "Name of the compute router to create"
}

variable "nat_name" {
  type        = string
  description = "Name of the NAT service in compute router"
}

variable "delegate_from" {
  description = "Identities to allow to impersonate created service account (in form of user:user.name@example.com, group:deployers@example.com or serviceAccount:sa1@project.iam.gserviceaccount.com)"
  type        = list(string)
}
