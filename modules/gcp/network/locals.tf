locals {
  create_vpc       = var.vpc_source == "create"
  use_existing_vpc = var.vpc_source == "existing"

  subnet_name = coalesce(var.subnet_name, "${var.prefix}-subnet-${var.suffix}")
}
