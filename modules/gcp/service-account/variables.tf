variable "google_project" {
  type        = string
  description = "Google project for VCP/workspace deployment"
}

variable "prefix" {
  type        = string
  description = "Prefix to use in generated service account name"
}

variable "delegate_from" {
  description = "Identities to allow to impersonate created service account (in form of user:user.name@example.com, group:deployers@example.com or serviceAccount:sa1@project.iam.gserviceaccount.com)"
  type        = list(string)
}
