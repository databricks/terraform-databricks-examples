
resource "random_string" "naming" {
  special = false
  upper   = false
  length  = 6
}

module "multiworkspace_demo" {
  source = "../modules/azure-vnet-injection"
  cidr_block   = var.cidr_block
  prefix   = var.prefix
  location = var.location
  tags = {
    Environment = var.environment
    Owner       = lookup(data.external.me.result, "name")
    Epoch       = random_string.naming.result
  }
}
/*
output "workspace_url" {
  value = module.multiworkspace_demo.workspace_url
}*/