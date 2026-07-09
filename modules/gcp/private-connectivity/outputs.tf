output "psc_subnet_self_link" {
  value       = google_compute_subnetwork.psc_subnet.self_link
  description = "Self-link of the PSC subnet"
}

output "frontend_forwarding_rule_name" {
  value       = var.enable_frontend ? google_compute_forwarding_rule.frontend_forwarding_rule_spoke[0].name : null
  description = "Name of the spoke-side frontend PSC forwarding rule (null when enable_frontend=false)"
}

output "backend_forwarding_rule_name" {
  value       = var.enable_backend ? google_compute_forwarding_rule.backend_forwarding_rule[0].name : null
  description = "Name of the backend (SCC) PSC forwarding rule (null when enable_backend=false)"
}

output "hub_frontend_forwarding_rule_name" {
  value       = var.create_hub && var.enable_frontend ? google_compute_forwarding_rule.frontend_forwarding_rule_hub[0].name : null
  description = "Name of the hub-side frontend PSC forwarding rule (null when no hub or no frontend)"
}

output "frontend_psc_ip_spoke" {
  value       = var.enable_frontend ? google_compute_address.frontend_address_spoke[0].address : null
  description = "IP address of the spoke-side frontend PSC endpoint"
}

output "backend_psc_ip_spoke" {
  value       = var.enable_backend ? google_compute_address.backend_address[0].address : null
  description = "IP address of the spoke-side backend PSC endpoint"
}

output "frontend_psc_ip_hub" {
  value       = var.create_hub && var.enable_frontend ? google_compute_address.frontend_address_hub[0].address : null
  description = "IP address of the hub-side frontend PSC endpoint (null when no hub)"
}
