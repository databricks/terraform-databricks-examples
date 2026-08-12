locals {
  create_spoke       = var.vpc_source == "create"
  use_existing_spoke = var.vpc_source == "existing"

  create_hub_vpc   = var.enable_hub && var.hub_vpc_source == "create"
  use_existing_hub = var.enable_hub && var.hub_vpc_source == "existing"

  subnet_name = coalesce(var.subnet_name, "${var.prefix}-subnet-${var.suffix}")
}
