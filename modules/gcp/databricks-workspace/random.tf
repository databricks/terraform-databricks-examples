resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false

  lifecycle {
    ignore_changes = [special, upper]
  }
}
