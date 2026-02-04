locals {
  autotermination = jsondecode(file("${path.module}/cluster_policy_json/autotermination.json"))
  dev_runtimes = jsondecode(file("${path.module}/cluster_policy_json/dev_runtimes.json"))
  prod_runtimes = jsondecode(file("${path.module}/cluster_policy_json/prod_runtimes.json"))
  ml_runtimes = jsondecode(file("${path.module}/cluster_policy_json/ml_runtimes.json"))
  job_cluster_types = jsondecode(file("${path.module}/cluster_policy_json/job_cluster_types.json"))
  sdp_cluster_types = jsondecode(file("${path.module}/cluster_policy_json/sdp_cluster_types.json"))

  required_tags = {
    "custom_tags.team" : {
      "type": "fixed",
      "value": "${var.team}"
    },
    "custom_tags.environment" : {
      "type": "fixed",
      "value": "${var.environment}"
    }    
  }

  cluster_policy_defaults = (
    {
      "personal-vm-dev" = merge(local.autotermination, local.required_tags, local.dev_runtimes)
      "personal-vm-prod" = merge(local.autotermination, local.required_tags, local.prod_runtimes)      
      "shared-compute-dev" = merge(local.autotermination, local.required_tags, local.dev_runtimes)
      "shared-compute-prod" = merge(local.autotermination, local.required_tags, local.prod_runtimes)      
      "power-user-dev" = merge(local.autotermination, local.required_tags, local.dev_runtimes)
      "power-user-prod" = merge(local.autotermination, local.required_tags, local.prod_runtimes)                   
      "job-cluster-dev" = merge(local.job_cluster_types, local.required_tags, local.dev_runtimes)
      "job-cluster-prod" = merge(local.job_cluster_types, local.required_tags, local.prod_runtimes)      
      "sdp-cluster-dev" = merge(local.sdp_cluster_types, local.required_tags, local.dev_runtimes)
      "sdp-cluster-prod" = merge(local.sdp_cluster_types, local.required_tags, local.prod_runtimes)                
    }
  )
}

resource "databricks_cluster_policy" "compute_policy" {
  name       = "${var.team} ${var.environment} ${var.policy_version} ${var.policy_key}"
  policy_family_id = var.policy_family_id
  policy_family_definition_overrides = jsonencode(merge(local.cluster_policy_defaults["${var.policy_key}-${var.environment}"], jsondecode(var.policy_overrides)))
}

resource "databricks_permissions" "policy_usage" {
  cluster_policy_id = databricks_cluster_policy.compute_policy.id

  dynamic "access_control" {
    for_each = toset(var.group_assignments)

    content {
      group_name = access_control.value
      permission_level = "CAN_USE"
    }
  }

  dynamic "access_control" {
    for_each = toset(var.service_principal_assignments)

    content {
      service_principal_name = access_control.value
      permission_level = "CAN_USE"
    }
  }
  
}