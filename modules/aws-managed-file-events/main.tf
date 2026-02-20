resource "databricks_storage_credential" "file_events" {
  name = local.storage_credential_name
  aws_iam_role {
    role_arn = local.iam_role_arn
  }
  skip_validation = true
  comment         = "Storage credential for managed file events - Managed by Terraform"
}

resource "databricks_grants" "storage_credential" {
  count              = length(var.storage_credential_grants) > 0 ? 1 : 0
  storage_credential = databricks_storage_credential.file_events.id

  dynamic "grant" {
    for_each = var.storage_credential_grants
    content {
      principal  = grant.value.principal
      privileges = grant.value.privileges
    }
  }
}

resource "databricks_external_location" "file_events" {
  name            = local.external_location_name
  url             = local.s3_url
  credential_name = databricks_storage_credential.file_events.id
  comment         = "External location with managed file events - Managed by Terraform"

  enable_file_events = true
  file_event_queue {
    managed_sqs {}
  }

  force_destroy = var.force_destroy_bucket

  depends_on = [
    aws_iam_role.file_events_access,
    time_sleep.wait_role_creation,
    aws_s3_bucket.file_events,
    aws_s3_bucket_public_access_block.file_events
  ]
}

resource "databricks_grants" "external_location" {
  count             = length(var.external_location_grants) > 0 ? 1 : 0
  external_location = databricks_external_location.file_events.id

  dynamic "grant" {
    for_each = var.external_location_grants
    content {
      principal  = grant.value.principal
      privileges = grant.value.privileges
    }
  }
}
