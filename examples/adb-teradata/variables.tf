variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID to deploy the workspace into"
}

variable "spokecidr" {
  type = string
}

variable "rglocation" {
  type = string
}

variable "dbfs_prefix" {
  type = string
}

variable "workspace_prefix" {
  type = string
}

variable "cidr" {
  type    = string
  default = "10.179.0.0/20"
}
