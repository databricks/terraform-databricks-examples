resource "aws_subnet" "db_firewall_subnet" {
  vpc_id                  = aws_vpc.db_vpc.id
  count                   = length(local.firewall_public_subnets_cidr)
  cidr_block              = element(local.firewall_public_subnets_cidr, count.index)
  availability_zone       = element(local.availability_zones, count.index)
  map_public_ip_on_launch = false
  tags = merge(var.tags, {
    Name = "${local.prefix}-db-firewall-public-${element(local.availability_zones, count.index)}"
  })
}

resource "aws_networkfirewall_rule_group" "databricks_fqdns_rg" {
  capacity = 100
  name     = "${local.prefix}-databricks-fqdns-rg"
  type     = "STATEFUL"
  rule_group {
    rules_source {
      rules_source_list {
        generated_rules_type = "ALLOWLIST"
        target_types         = ["TLS_SNI", "HTTP_HOST"]
        targets              = concat([var.db_web_app, var.db_tunnel, var.db_rds, local.db_root_bucket], var.whitelisted_urls)
      }
    }
    rule_variables {
      ip_sets {
        key = "HOME_NET"
        ip_set {
          definition = [var.cidr_block]
        }
      }
    }
  }
  tags = var.tags
}

resource "aws_networkfirewall_rule_group" "allow_db_cpl_protocols_rg" {
  capacity    = 100
  description = "Allows control plane traffic from source"
  name        = "${local.prefix}-allow-db-cpl-protocols-rg"
  type        = "STATEFUL"
  rule_group {
    rule_variables {
      ip_sets {
        key = "HOME_NET"
        ip_set {
          definition = [var.cidr_block]
        }
      }
    }
    rules_source {
      dynamic "stateful_rule" {
        for_each = local.protocols_control_plane
        content {
          action = "PASS"
          header {
            destination      = var.db_control_plane
            destination_port = "443"
            protocol         = stateful_rule.value
            direction        = "ANY"
            source_port      = "ANY"
            source           = "ANY"
          }
          rule_option {
            keyword = "sid:${stateful_rule.key + 1}"
          }
        }
      }
    }
  }

  tags = var.tags
}

resource "aws_networkfirewall_rule_group" "deny_protocols_rg" {
  capacity    = 100
  description = "Drops FTP,ICMP, SSH traffic from source"
  name        = "${local.prefix}-deny-protocols-rg"
  type        = "STATEFUL"
  rule_group {
    rule_variables {
      ip_sets {
        key = "HOME_NET"
        ip_set {
          definition = [var.cidr_block]
        }
      }
    }
    rules_source {
      dynamic "stateful_rule" {
        for_each = local.protocols
        content {
          action = "DROP"
          header {
            destination      = "ANY"
            destination_port = "ANY"
            protocol         = stateful_rule.value
            direction        = "ANY"
            source_port      = "ANY"
            source           = "ANY"
          }
          rule_option {
            keyword = "sid:${stateful_rule.key + 1}"
          }
        }
      }
    }
  }

  tags = var.tags
}

resource "aws_networkfirewall_firewall_policy" "egress_policy" {
  name = "${local.prefix}-egress-policy"
  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]
    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.databricks_fqdns_rg.arn
    }
    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.deny_protocols_rg.arn
    }
    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.allow_db_cpl_protocols_rg.arn
    }
  }
  tags = var.tags
}

resource "aws_networkfirewall_firewall" "exfiltration_firewall" {
  name                = "${local.prefix}-fw"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.egress_policy.arn
  vpc_id              = aws_vpc.db_vpc.id
  dynamic "subnet_mapping" {
    for_each = aws_subnet.db_firewall_subnet[*].id
    content {
      subnet_id = subnet_mapping.value
    }
  }
  tags = var.tags
}