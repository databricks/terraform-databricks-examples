
output "workspaces_urls" {
  value = {
    "env1" = [for workspace in module.multiple_workspaces["env1"].databricks_host : workspace]
    /*
    "env2" = [for workspace in module.multiple_workspaces["env2"].databricks_host : workspace]
    */
  }
}
