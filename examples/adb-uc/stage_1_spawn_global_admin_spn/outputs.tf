output "aad_global_admin_spn_object_id" {
  value = azuread_service_principal.example.object_id
}
