module "adb-with-private-link-standard" {
  source       = "github.com/databricks/terraform-databricks-examples/modules/adb-with-private-link-standard"
  cidr_transit = var.cidr_transit
  cidr_dp      = var.cidr_dp
  location     = var.location
}
