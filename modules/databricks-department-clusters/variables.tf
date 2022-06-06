variable "cluster_name" {
  type = string
}
variable "department" {
  type = string
}
variable "user_names" {
    type = list(string)
}
variable "group_name" {
  type = string
}
variable "prefix" {}
variable "tags" {
  type        = map(string)
  description = "Tags applied to all resources created"
}