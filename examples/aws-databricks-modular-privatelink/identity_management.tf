# metastore admin group
resource "databricks_group" "metastore_admin_group" {
  provider     = databricks.mws
  display_name = local.user_config.tf_admin_groups.metastore_admin_group.display_name
}

// use the spn that was manually created
data "databricks_service_principal" "spn" {
  provider       = databricks.mws
  application_id = var.client_id
}

resource "databricks_group_member" "metastore_admin_group_member_spn" {
  provider  = databricks.mws
  group_id  = databricks_group.metastore_admin_group.id
  member_id = data.databricks_service_principal.spn.id
}

locals {
  user_config                      = yamldecode(file("${path.module}/configs/account_users.yaml"))
  metastore_admin_new_members      = lookup(local.user_config.tf_admin_groups.metastore_admin_group.members, "new_metastore_admins", [])
  metastore_admin_existing_members = lookup(local.user_config.tf_admin_groups.metastore_admin_group.members, "existing_metastore_admins", [])

  # Create flattened list of terraform-managed group memberships
  terraform_group_memberships = flatten([
    for group_name, group in local.user_config.tf_non_admin_groups : [
      for username in group.members : {
        group_name = group_name
        user_name  = username
      }
    ]
  ])
}

####### users #######
# Create new users
resource "databricks_user" "new_users" {
  provider     = databricks.mws
  for_each     = local.user_config.new_users
  user_name    = each.key
  display_name = each.value.display_name
}

# Import existing users that you want to interact with terraform, for example, assign them into groups via TF
data "databricks_user" "existing_users" {
  provider  = databricks.mws
  for_each  = toset(local.user_config.existing_users)
  user_name = each.value
}

####### metastore admin group #######
# Add new metastore admins to metastore admin group
resource "databricks_group_member" "metastore_admin_new_members" {
  provider  = databricks.mws
  for_each  = toset(local.metastore_admin_new_members)
  group_id  = databricks_group.metastore_admin_group.id
  member_id = databricks_user.new_users[each.value].id
}

# Add existing metastore admins to metastore admin group
data "databricks_user" "metastore_admin_existing_users" {
  provider  = databricks.mws
  for_each  = toset(local.metastore_admin_existing_members)
  user_name = each.value
}

resource "databricks_group_member" "metastore_admin_existing_members" {
  provider  = databricks.mws
  for_each  = toset(local.metastore_admin_existing_members)
  group_id  = databricks_group.metastore_admin_group.id
  member_id = data.databricks_user.metastore_admin_existing_users[each.value].id
}

####### groups #######
resource "databricks_group" "tf_non_admin_groups" {
  provider     = databricks.mws
  for_each     = local.user_config.tf_non_admin_groups
  display_name = each.value.display_name
}
resource "databricks_group_member" "tf_group_members" {
  provider = databricks.mws
  for_each = {
    for membership in local.terraform_group_memberships :
    "${membership.group_name}-${membership.user_name}" => membership
  }
  group_id  = databricks_group.tf_non_admin_groups[each.value.group_name].id
  member_id = contains(keys(databricks_user.new_users), each.value.user_name) ? databricks_user.new_users[each.value.user_name].id : data.databricks_user.existing_users[each.value.user_name].id
}

####### add users to workspace #######
# Add all users from yaml file into desired workspace, below is example for env1 1 workspace
resource "databricks_mws_permission_assignment" "add_users_to_workspace" {
  provider     = databricks.mws
  for_each     = local.user_config.new_users
  workspace_id = module.multiple_workspaces["env1"].workspace_ids[0]
  principal_id = databricks_user.new_users[each.key].id
  permissions  = ["USER"]
}
