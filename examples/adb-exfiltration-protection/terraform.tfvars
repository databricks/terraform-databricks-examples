subscription_id  = "<your Azure Subscription ID here>"
dbfs_prefix      = "dbfs"
workspace_prefix = "adb"
hubcidr          = "10.178.0.0/20"
spokecidr        = "10.179.0.0/20"
rglocation       = "westeurope"

# We can pull this information automatically, i.e. from
# https://github.com/microsoft/AzureTRE/blob/main/templates/workspace_services/databricks/terraform/databricks-udr.json
# that is maintained by Microsoft team (although it may not be updated immediately).
metastore = [
  "consolidated-westeurope-prod-metastore.mysql.database.azure.com",
  "consolidated-westeurope-prod-metastore-addl-1.mysql.database.azure.com",
  "consolidated-westeurope-prod-metastore-addl-2.mysql.database.azure.com",
  "consolidated-westeurope-prod-metastore-addl-3.mysql.database.azure.com",
  "consolidated-westeuropec2-prod-metastore-0.mysql.database.azure.com",
  "consolidated-westeuropec2-prod-metastore-1.mysql.database.azure.com",
  "consolidated-westeuropec2-prod-metastore-2.mysql.database.azure.com",
  "consolidated-westeuropec2-prod-metastore-3.mysql.database.azure.com",
]

// get from https://learn.microsoft.com/en-us/azure/databricks/resources/supported-regions#--metastore-artifact-blob-storage-system-tables-blob-storage-log-blob-storage-and-event-hub-endpoint-ip-addresses
scc_relay = [
  "tunnel.westeurope.azuredatabricks.net",
  "tunnel.westeuropec2.azuredatabricks.net"
]
webapp_ips = [
  "52.232.19.246/32",
  "40.74.30.80/32",
  "20.103.219.240/28",
  "4.150.168.160/28",
]
eventhubs = [
  "prod-westeurope-observabilityeventhubs.servicebus.windows.net",
  "prod-westeuc2-observabilityeventhubs.servicebus.windows.net",
]
firewallfqdn = [                                 // dbfs rule will be added - depends on dbfs storage name
  "dbartifactsprodwesteu.blob.core.windows.net", //databricks artifacts
  "arprodwesteua1.blob.core.windows.net",
  "arprodwesteua2.blob.core.windows.net",
  "arprodwesteua3.blob.core.windows.net",
  "arprodwesteua4.blob.core.windows.net",
  "arprodwesteua5.blob.core.windows.net",
  "arprodwesteua6.blob.core.windows.net",
  "arprodwesteua7.blob.core.windows.net",
  "arprodwesteua8.blob.core.windows.net",
  "arprodwesteua9.blob.core.windows.net",
  "arprodwesteua10.blob.core.windows.net",
  "arprodwesteua11.blob.core.windows.net",
  "arprodwesteua12.blob.core.windows.net",
  "arprodwesteua13.blob.core.windows.net",
  "arprodwesteua14.blob.core.windows.net",
  "arprodwesteua15.blob.core.windows.net",
  "arprodwesteua16.blob.core.windows.net",
  "arprodwesteua17.blob.core.windows.net",
  "arprodwesteua18.blob.core.windows.net",
  "arprodwesteua19.blob.core.windows.net",
  "arprodwesteua20.blob.core.windows.net",
  "arprodwesteua21.blob.core.windows.net",
  "arprodwesteua22.blob.core.windows.net",
  "arprodwesteua23.blob.core.windows.net",
  "arprodwesteua24.blob.core.windows.net",
  "dbartifactsprodnortheu.blob.core.windows.net", //databricks artifacts secondary
  "ucstprdwesteu.dfs.core.windows.net",           // system tables storage
  "dblogprodwesteurope.blob.core.windows.net",    //log blob
  "cdnjs.com",                                    //ganglia
  // Azure monitor
  "global.handler.control.monitor.azure.com",
  "westeurope.handler.control.monitor.azure.com",
]

