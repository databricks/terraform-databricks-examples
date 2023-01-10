resource "random_string" "naming" {
  special = false
  upper   = false
  length  = 6
}

locals {
  prefix   = join("-", [var.workspace_prefix, "${random_string.naming.result}"])
  location = var.rglocation
  dbfsname = join("", [var.dbfs_prefix, "${random_string.naming.result}"]) // dbfs name must not have special chars

  // tags that are propagated down to all resources
  tags = {
    Environment = "Testing"
    Owner       = lookup(data.external.me.result, "name")
    Epoch       = random_string.naming.result
  }
}

resource "azurerm_resource_group" "this" {
  name     = "adb-teradata-${local.prefix}-rg"
  location = local.location
  tags     = local.tags
}

resource "local_file" "setupscript" {
  content         = <<EOT
  #! /bin/bash
  sudo apt update
  sudo apt install docker.io -y
  sudo apt install docker-compose -y
  EOT
  filename        = "teradata_setup.sh"
  file_permission = "0777" // default value 0777
}


module "test_vm_instance" {
  source              = "./modules/teradata_vm"
  resource_group_name = azurerm_resource_group.this.name
  naming_prefix       = local.prefix
  region              = local.location
  subnet_id           = azurerm_subnet.teradatasubnet.id
}
