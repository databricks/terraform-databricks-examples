output "spoke_vpc_id" {
  value = local.create_spoke ? google_compute_network.spoke_vpc[0].id : (
    local.use_existing_spoke ? data.google_compute_network.existing_spoke[0].id : null
  )
  description = "ID of the spoke VPC"
}

output "spoke_vpc_name" {
  value = local.create_spoke ? google_compute_network.spoke_vpc[0].name : (
    local.use_existing_spoke ? data.google_compute_network.existing_spoke[0].name : null
  )
  description = "Name of the spoke VPC"
}

output "spoke_vpc_self_link" {
  value = local.create_spoke ? google_compute_network.spoke_vpc[0].self_link : (
    local.use_existing_spoke ? data.google_compute_network.existing_spoke[0].self_link : null
  )
  description = "Self-link of the spoke VPC"
}

output "spoke_subnet_id" {
  value = local.create_spoke ? google_compute_subnetwork.spoke_subnet[0].id : (
    local.use_existing_spoke ? data.google_compute_subnetwork.existing_spoke_subnet[0].id : null
  )
  description = "ID of the spoke subnet"
}

output "spoke_subnet_name" {
  value = local.create_spoke ? google_compute_subnetwork.spoke_subnet[0].name : (
    local.use_existing_spoke ? data.google_compute_subnetwork.existing_spoke_subnet[0].name : null
  )
  description = "Name of the spoke subnet"
}

output "spoke_subnet_self_link" {
  value = local.create_spoke ? google_compute_subnetwork.spoke_subnet[0].self_link : (
    local.use_existing_spoke ? data.google_compute_subnetwork.existing_spoke_subnet[0].self_link : null
  )
  description = "Self-link of the spoke subnet"
}

output "nat_id" {
  value       = local.create_spoke && var.enable_nat ? google_compute_router_nat.nat[0].id : null
  description = "ID of the Cloud NAT (null when vpc_source=existing or enable_nat=false)"
}

output "hub_vpc_id" {
  value = local.create_hub_vpc ? google_compute_network.hub_vpc[0].id : (
    local.use_existing_hub ? data.google_compute_network.existing_hub[0].id : null
  )
  description = "ID of the hub VPC (null when the hub is disabled)"
}

output "hub_vpc_name" {
  value = local.create_hub_vpc ? google_compute_network.hub_vpc[0].name : (
    local.use_existing_hub ? data.google_compute_network.existing_hub[0].name : null
  )
  description = "Name of the hub VPC (null when the hub is disabled)"
}

output "hub_vpc_self_link" {
  value = local.create_hub_vpc ? google_compute_network.hub_vpc[0].self_link : (
    local.use_existing_hub ? data.google_compute_network.existing_hub[0].self_link : null
  )
  description = "Self-link of the hub VPC (null when the hub is disabled)"
}

output "hub_subnet_name" {
  value = local.create_hub_vpc ? google_compute_subnetwork.hub_subnet[0].name : (
    local.use_existing_hub ? data.google_compute_subnetwork.existing_hub_subnet[0].name : null
  )
  description = "Name of the hub subnet (null when the hub is disabled)"
}
