locals { // hard coded values, using this repo's directory structure
  json_files = fileset("${path.root}/../aws_databricks_modular_privatelink/artifacts", "*.json")
  json_data_map = tomap({
    for k, f in local.json_files : k => jsondecode(file("${path.root}/../aws_databricks_modular_privatelink/artifacts/${f}"))
  })

  allow_lists_map = tomap({
    for k, ws in local.json_data_map : trimsuffix(k, ".json") => ws.allow_list
  })

  block_lists_map = tomap({
    for k, ws in local.json_data_map : trimsuffix(k, ".json") => ws.block_list
  })
}

module "ip_access_list_workspace_1" {
  providers = {
    databricks = databricks.ws1 // manually adding each workspace's module and match with provider
  }

  source           = "./modules/ip_access_list"
  allow_list       = local.allow_lists_map.workspace_1
  block_list       = local.block_lists_map.workspace_1
  allow_list_label = "Allow List for workspace_1 "
  deny_list_label  = "Deny List for workspace_1 "
}

module "ip_access_list_workspace_2" {
  providers = {
    databricks = databricks.ws2 // manually adding each workspace's module and match with provider
  }

  source           = "./modules/ip_access_list"
  allow_list       = local.allow_lists_map.workspace_2
  block_list       = local.block_lists_map.workspace_2
  allow_list_label = "Allow List for workspace_2 "
  deny_list_label  = "Deny List for workspace_2 "
}


resource "databricks_group" "this" {
  provider                   = databricks.ws1
  display_name               = "engineering"
  allow_cluster_create       = true
  allow_instance_pool_create = true
}

data "databricks_user" "this" { // using data to add the existing user into group
  provider  = databricks.ws1
  user_name = "goinfrerie@gmail.com"
}

resource "databricks_user" "user2" { // ordinary user, non-admin
  provider  = databricks.ws1
  user_name = "hao.wang@databricks.com"
}

resource "databricks_group_member" "vip_member" {
  provider  = databricks.ws1
  group_id  = databricks_group.this.id
  member_id = data.databricks_user.this.id
}

module "engineering_compute_policy" {
  providers = {
    databricks = databricks.ws1
  }
  source = "./modules/base_policy"
  team   = "engineering"
  policy_overrides = {
    "dbus_per_hour" : {
      "type" : "range",
      "maxValue" : 50 // only engineering guys can spin up big clusters
    },
  }
  depends_on = [
    databricks_group.this,
  ]
}
