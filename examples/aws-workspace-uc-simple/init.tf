data "aws_caller_identity" "current" {}

locals {
  prefix                        = "demo-${random_string.naming.result}"
  unity_admin_group             = "${local.prefix}-${var.unity_admin_group}"
  workspace_users_group         = "${local.prefix}-workspace-users"
  aws_access_services_role_name = var.aws_access_services_role_name == null ? "${local.prefix}-aws-services-role" : "${local.prefix}-${var.aws_access_services_role_name}"
  aws_access_services_role_arn  = "arn:aws:iam::${local.aws_account_id}:role/${local.aws_access_services_role_name}"
  aws_account_id                = data.aws_caller_identity.current.account_id
  tags                          = merge(var.tags, { Owner = split("@", var.my_username)[0], ownerEmail = var.my_username })
}

resource "random_string" "naming" {
  special = false
  upper   = false
  length  = 6
}
