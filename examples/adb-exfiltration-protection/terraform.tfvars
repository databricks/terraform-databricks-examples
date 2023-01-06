hubcidr          = "10.178.0.0/20"
spokecidr        = "10.179.0.0/20"
no_public_ip     = true
rglocation       = "southeastasia"
metastoreip      = "40.78.233.2"
sccip            = "52.230.27.216/32" // get scc ip from nslookup 
webappip         = "52.187.145.107/32"
dbfs_prefix      = "dbfs"
workspace_prefix = "adb"
firewallfqdn = [                                                      // dbfs rule will be added - depends on dbfs storage name
  "dbartifactsprodseap.blob.core.windows.net",                        //databricks artifacts
  "dbartifactsprodeap.blob.core.windows.net",                         //databricks artifacts secondary
  "dblogprodseasia.blob.core.windows.net",                            //log blob
  "prod-southeastasia-observabilityeventhubs.servicebus.windows.net", //eventhub
  "cdnjs.com",                                                        //ganglia
]
