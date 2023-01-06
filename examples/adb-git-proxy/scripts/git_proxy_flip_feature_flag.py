# Databricks notebook source
dbutils.widgets.text("cluster-name", "git-proxy", "Git Proxy Cluster Name")
cluster_name = dbutils.widgets.get("cluster-name")

# COMMAND ----------

import requests
admin_token = dbutils.notebook.entry_point.getDbutils().notebook().getContext().apiToken().get()
databricks_instance = dbutils.notebook.entry_point.getDbutils().notebook().getContext().apiUrl().get()

headers = {"Authorization": f"Bearer {admin_token}"}
# Workspace Conf
WORKSPACE_CONF_ENDPOINT = "/api/2.0/workspace-conf"

patch_enable_git_proxy_data = {
  "enableGitProxy": "true"
}
patch_git_proxy_cluster_name_data = {
  "gitProxyClusterName": cluster_name
}
requests.patch(databricks_instance + WORKSPACE_CONF_ENDPOINT, headers=headers, json=patch_enable_git_proxy_data)
requests.patch(databricks_instance + WORKSPACE_CONF_ENDPOINT, headers=headers, json=patch_git_proxy_cluster_name_data)

# validate the flag has been turned on
get_flag_response = requests.get(databricks_instance + WORKSPACE_CONF_ENDPOINT + "?keys=enableGitProxy", headers=headers).json()
get_cluster_name_response = requests.get(databricks_instance + WORKSPACE_CONF_ENDPOINT + "?keys=gitProxyClusterName", headers=headers).json()
print(f"Get enableGitProxy response: {get_flag_response}")
print(f"Get gitProxyClusterName response: {get_cluster_name_response}")
