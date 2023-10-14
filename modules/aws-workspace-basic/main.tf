resource "random_string" "naming" {
  special = false
  upper   = false
  length  = 6
}

locals {
  prefix = var.prefix != "" ? var.prefix : "demo${random_string.naming.result}"
}
