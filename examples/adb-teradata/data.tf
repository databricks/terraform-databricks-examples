data "azurerm_client_config" "current" {
}

data "external" "me" {
  program = ["az", "account", "show", "--query", "user"]
}

data "http" "my_public_ip" {
  url = "https://ipinfo.io"
}