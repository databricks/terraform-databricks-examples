databricks_account_id = ""

google_region = ""

workspace_google_project = ""

spoke_vpc_google_project = ""
hub_vpc_google_project   = ""
is_spoke_vpc_shared      = true

prefix = ""

hive_metastore_ip = ""
hub_vpc_cidr      = ""
spoke_vpc_cidr    = ""
subnet_cidr       = ""
psc_subnet_cidr   = ""

metastore_name = ""
catalog_name   = ""

serverless_egress_mode                   = "restricted"
serverless_allowed_internet_destinations = []
serverless_allowed_storage_destinations  = []
serverless_egress_enforcement            = "enforced"

cmek_managed_services_key_id = null
cmek_storage_key_id          = null

enable_compliance_security_profile  = false
compliance_standards                = []
enable_enhanced_security_monitoring = false
enable_automatic_cluster_update     = false
ip_access_lists                     = []
