# Network Firewall Component
# Creates AWS Network Firewall in the Hub VPC with configurable rule groups for advanced security
# Note: Firewall subnets are created in transit-gateway.tf as part of the Hub VPC

# Rule Group - Allow FQDNs (Domain-based filtering)
resource "aws_networkfirewall_rule_group" "allow_fqdns" {
  count    = length(var.allowed_fqdns) > 0 ? 1 : 0
  capacity = 100
  name     = "${var.prefix}-allow-fqdns-rg"
  type     = "STATEFUL"
  
  rule_group {
    rule_variables {
      ip_sets {
        key = "HOME_NET"
        ip_set {
          definition = [var.spoke_vpc_cidr]
        }
      }
    }
    
    rules_source {
      # Domain-based rules
      rules_source_list {
        generated_rules_type = "ALLOWLIST"
        target_types         = ["TLS_SNI", "HTTP_HOST"]
        targets              = var.allowed_fqdns
      }
    }
  }
  
  tags = merge(var.common_tags, {
    Name = "${var.prefix}-allow-fqdns-rg"
  })
}

# Rule Group - Allow Network Rules (IP, Protocol, Port based filtering)
resource "aws_networkfirewall_rule_group" "allow_network" {
  count    = length(var.allowed_network_rules) > 0 ? 1 : 0
  capacity = 100
  name     = "${var.prefix}-allow-network-rg"
  type     = "STATEFUL"
  
  rule_group {
    rule_variables {
      ip_sets {
        key = "HOME_NET"
        ip_set {
          definition = [var.spoke_vpc_cidr]
        }
      }
    }
    
    rules_source {
      # Network-level rules from variable
      dynamic "stateful_rule" {
        for_each = var.allowed_network_rules
        content {
          action = "PASS"
          header {
            direction        = "FORWARD"
            protocol         = upper(stateful_rule.value.protocol)
            source           = stateful_rule.value.source_ip
            source_port      = "ANY"
            destination      = stateful_rule.value.destination_ip
            destination_port = stateful_rule.value.destination_port
          }
          rule_option {
            keyword  = "sid"
            settings = [tostring(stateful_rule.key + 1)]
          }
        }
      }
    }
  }
  
  tags = merge(var.common_tags, {
    Name = "${var.prefix}-allow-network-rg"
  })
}

# Rule Group - Deny All Other Traffic (Default Deny)
resource "aws_networkfirewall_rule_group" "deny_all" {
  capacity = 10
  name     = "${var.prefix}-deny-all-rg"
  type     = "STATEFUL"
  
  rule_group {
    rule_variables {
      ip_sets {
        key = "HOME_NET" 
        ip_set {
          definition = [var.spoke_vpc_cidr]
        }
      }
    }
    
    rules_source {
      stateful_rule {
        action = "DROP"
        header {
          direction        = "FORWARD"
          protocol         = "IP"
          source           = "$HOME_NET"
          source_port      = "ANY"
          destination      = "ANY"
          destination_port = "ANY"
        }
        rule_option {
          keyword  = "sid"
          settings = ["100"]
        }
      }
    }
  }
  
  tags = merge(var.common_tags, {
    Name = "${var.prefix}-deny-all-rg"
  })
}

# Firewall Policy
resource "aws_networkfirewall_firewall_policy" "main" {
  name = "${var.prefix}-firewall-policy"
  
  firewall_policy {
    # Reference FQDN rule group if FQDNs are provided
    dynamic "stateful_rule_group_reference" {
      for_each = length(var.allowed_fqdns) > 0 ? [1] : []
      content {
        priority     = 1
        resource_arn = aws_networkfirewall_rule_group.allow_fqdns[0].arn
      }
    }
    
    # Reference Network rule group if network rules are provided
    dynamic "stateful_rule_group_reference" {
      for_each = length(var.allowed_network_rules) > 0 ? [1] : []
      content {
        priority     = 2
        resource_arn = aws_networkfirewall_rule_group.allow_network[0].arn
      }
    }
    
    # Deny all - lowest priority (always applied)
    stateful_rule_group_reference {
      priority     = 100
      resource_arn = aws_networkfirewall_rule_group.deny_all.arn
    }
    
    # Default action for stateless rules - forward to stateful engine
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]
  }
  
  tags = merge(var.common_tags, {
    Name = "${var.prefix}-firewall-policy"
  })
}

# Network Firewall
resource "aws_networkfirewall_firewall" "main" {
  name                = "${var.prefix}-network-firewall"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.main.arn
  vpc_id              = aws_vpc.hub.id
  
  # Deploy firewall endpoint in hub VPC firewall subnet
  subnet_mapping {
    subnet_id = aws_subnet.hub_firewall.id
  }
  
  tags = merge(var.common_tags, {
    Name = "${var.prefix}-network-firewall"
  })
}
