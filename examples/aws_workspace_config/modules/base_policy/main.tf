terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
  }
}

locals {
  default_policy = {
    "dbus_per_hour" : {
      "type" : "range",
      "maxValue" : 10
    },
    "autotermination_minutes" : {
      "type" : "fixed",
      "value" : 20,
      "hidden" : true
    },
    "custom_tags.Team" : {
      "type" : "fixed",
      "value" : var.team
    }
  }
}

resource "databricks_cluster_policy" "fair_use" {
  name       = "${var.team} cluster policy"
  definition = jsonencode(merge(local.default_policy, var.policy_overrides))
}

resource "databricks_permissions" "can_use_cluster_policyinstance_profile" {
  cluster_policy_id = databricks_cluster_policy.fair_use.id
  access_control {
    group_name       = var.team
    permission_level = "CAN_USE"
  }
}
