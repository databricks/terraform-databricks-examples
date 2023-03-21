variable "databricks_account_id" {
  default = "f187f55a-9d3d-463b-aa1a-d55818b704c9"
}

variable "google_project" {
  default = "fe-dev-sandbox"
}
variable "google_region" {
    default = "europe-west1"
}
variable "google_zone" {
    default = "europe-west1-a"
}
variable "prefix" {
    default = "aleks421"
}


variable "delegate_from" {
 description = "Allow either user:user.name@example.com, group:deployers@example.com or serviceAccount:sa1@project.iam.gserviceaccount.com to impersonate created service account"
 type        = list(string)
 default = [ "user:aleksander.callebat@databricks.com" ]
}
