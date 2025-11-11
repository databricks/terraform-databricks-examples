# Hub Networking Module Variables
# This module creates Transit Gateway, Hub VPC, and Network Firewall

variable "prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "spoke_vpc_id" {
  description = "ID of the spoke (main) VPC"
  type        = string
}

variable "spoke_vpc_cidr" {
  description = "CIDR block of the spoke (main) VPC"
  type        = string
}

variable "spoke_private_subnet_ids" {
  description = "IDs of the spoke VPC private subnets"
  type        = list(string)
}

variable "spoke_route_table_ids" {
  description = "IDs of the spoke VPC private route tables"
  type        = list(string)
}

variable "hub_vpc_cidr" {
  description = "CIDR block for the hub VPC"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "enable_firewall" {
  description = "Enable Network Firewall in the hub VPC"
  type        = bool
  default     = true
}

variable "allowed_fqdns" {
  description = "List of FQDNs to allow through the firewall"
  type        = list(string)
  default     = []
}

variable "allowed_network_rules" {
  description = "List of network-level rules (IP, protocol, port)"
  type = list(object({
    protocol         = string
    source_ip        = string
    destination_ip   = string
    destination_port = string
  }))
  default = []
}

