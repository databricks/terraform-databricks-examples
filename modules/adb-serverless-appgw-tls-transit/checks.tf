check "backend_target" {
  assert {
    condition     = length(var.backend_addresses) + length(var.backend_fqdns) > 0
    error_message = "Provide at least one backend address or backend FQDN."
  }
}
