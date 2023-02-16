provider "azurerm" {
  features {}
}

provider "random" {
}

provider "null" {
}

provider "local" {
}

resource "random_string" "naming" {
  special = false
  upper   = false
  length  = 6
}

data "azurerm_client_config" "current" {
}

data "external" "me" {
  program = ["az", "account", "show", "--query", "user"]
}

resource "azurerm_resource_group" "coldstart_image_rg" {
  name     = "${local.prefix}-rg"
  location = local.location
  tags     = local.tags
}

resource "local_file" "packer_config" {
  content  = <<-EOT
    managed_img_name="${local.prefix}-image"
    managed_img_rg_name="${azurerm_resource_group.coldstart_image_rg.name}"
    subscription_id="${data.azurerm_client_config.current.subscription_id}"
  EOT
  filename = "../os/variables.auto.pkrvars.hcl"
  depends_on = [
    azurerm_resource_group.coldstart_image_rg,
  ]
}
