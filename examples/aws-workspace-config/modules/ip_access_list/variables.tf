variable "allow_list" {
  type = list(string)
}

variable "block_list" {
  type = list(string)
}

variable "allow_list_label" {
  type    = string
  default = "Allow List"
}

variable "deny_list_label" {
  type    = string
  default = "Deny List"
}
