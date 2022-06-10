terraform {
  backend "azurerm" {
    resource_group_name  = "home"
    storage_account_name = "tfbackendsahome"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}
