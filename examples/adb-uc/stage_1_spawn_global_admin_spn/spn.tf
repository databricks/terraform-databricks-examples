data "azuread_client_config" "current" {}

resource "azuread_application" "example" {
  display_name = "spn-tf-1"
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "example" {
  application_id               = azuread_application.example.application_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]
}

resource "azuread_directory_role_assignment" "global_administrator" {
  role_id             = "62e90394-69f5-4237-9190-012177145e10" # Global Administrator templateID
  principal_object_id = azuread_service_principal.example.object_id
}
