variable "databricks_account_id" {
}
variable "databricks_google_service_account" {
  # Input the service account email adress generated via gcp-sa-provisionning
}


variable "google_project" {
}
variable "google_region" {
}
variable "google_zone" {
}
variable "prefix" {
}

variable "workspace_name" {

}

variable "delegate_from" {
  description = "Allow either user:user.name@example.com, group:deployers@example.com or serviceAccount:sa1@project.iam.gserviceaccount.com to impersonate created service account"
  type        = list(string)
}


