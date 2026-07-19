module "uc_external_location_file_events" {
  source = "../../modules/adb-uc-external-location-file-events"

  name_prefix         = var.name_prefix
  access_connector_id = var.access_connector_id
  storage_account_id  = var.storage_account_id
  resource_group_name = var.resource_group_name

  external_locations = [
    {
      name    = var.external_location_name
      url     = var.external_location_url
      comment = "Landing zone with managed AQS file events"
    }
  ]

  credential_grants = var.grant_principal == "" ? [] : [
    {
      principal  = var.grant_principal
      privileges = ["CREATE_EXTERNAL_LOCATION", "READ_FILES", "WRITE_FILES"]
    }
  ]

  location_grants = var.grant_principal == "" ? [] : [
    {
      principal  = var.grant_principal
      privileges = ["BROWSE", "READ_FILES", "WRITE_FILES", "CREATE_EXTERNAL_TABLE", "CREATE_EXTERNAL_VOLUME"]
    }
  ]
}
