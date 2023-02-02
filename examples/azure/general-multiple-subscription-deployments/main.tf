provider "azurerm" {
  features {}
}

# second subscription to deploy
provider "azurerm" {
  features {}
  alias           = "secondsubscription"
  subscription_id = var.second_subscription_id
}

provider "random" {
}

provider "local" {
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

resource "azurerm_resource_group" "rg1" {
  name     = "${local.prefix}-rg-1"
  location = local.location
  tags     = local.tags
}

# create a resource group in the second subscription, to use existing resources from subscription 2, use data
resource "azurerm_resource_group" "rg2" {
  provider = azurerm.secondsubscription
  name     = "${local.prefix}-rg-2"
  location = local.location
  tags     = local.tags
}
