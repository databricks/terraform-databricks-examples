variable "cluster_name" {}
variable "department" {}
variable "user_name" {}
variable "group_name" {}
variable "prefix" {}
variable "tags" {
  type        = map(string)
  description = "Tags applied to all resources created"
}