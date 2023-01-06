variable "rglocation" {
  type    = string
  default = "southeastasia"
}

variable "workspace_prefix" {
  type    = string
  default = "coldstart"
}

# the 2 vars below must be the same to packer config
variable "managed_image_name_prefix" {
  type    = string
  default = "squid_img"
}

variable "managed_image_resource_group_name_prefix" {
  type    = string
  default = "squid"
}

locals {
  prefix   = join("-", [var.workspace_prefix, "${random_string.naming.result}"])
  location = var.rglocation
  // tags that are propagated down to all resources
  tags = {
    Environment = "Testing"
    Owner       = lookup(data.external.me.result, "name")
    Epoch       = random_string.naming.result
  }
}
