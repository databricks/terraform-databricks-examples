module "adb-with-private-link-standard" {
  source                                  = "../../modules/adb-with-private-link-standard"
  cidr_transit                            = var.cidr_transit
  cidr_dp                                 = var.cidr_dp
  location                                = var.location
  existing_data_plane_resource_group_name = var.existing_data_plane_resource_group_name
  create_data_plane_resource_group        = var.create_data_plane_resource_group
  existing_transit_resource_group_name    = var.existing_transit_resource_group_name
  create_transit_resource_group           = var.create_transit_resource_group
}
