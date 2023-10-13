variable "databricks_account_id" {
}

variable "google_project" {
}
variable "google_region" {
}
variable "prefix" {
}

variable "workspace_name" {

}

variable "delegate_from" {
  description = "Allow either user:user.name@example.com, group:deployers@example.com or serviceAccount:sa1@project.iam.gserviceaccount.com to impersonate created service account"
  type        = list(string)
}


