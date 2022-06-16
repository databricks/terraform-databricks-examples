variable "cluster_name" {
  type        = string
  description = "Name of the shared cluster to create"
}
variable "department" {
  type        = string
  description = "Department name"
}
variable "user_names" {
  type        = list(string)
  description = "List of users to create in the specified group"
  default     = []
}
variable "group_name" {
  type        = string
  description = "Name of the group to create"
}
variable "tags" {
  type        = map(string)
  description = "Additional tags applied to all resources created"
  default     = {}
}
