# databricks-department-clusters


This module creates specific Databricks objects for a given department:

* User group for a department with specific users added to it
* A shared Databricks cluster that could be used by users of the group
* A Databricks SQL Endpoint
* A Databricks cluster policy that could be used by the user group


## Inputs

+----------+-----------+---------+----------+----------+
|Name      |Description|Type     |Default   |Required  |
|----------|-----------|---------|----------|:--------:|
|`cluster_name`|Name of the shared cluster to create|string||yes|
+----------+----------+----------+----------+----------+
|`department`|Department name|string||yes|
+----------+----------+----------+----------+----------+
|`user_names`|List of users to create in the specified group|list(string)|empty|no|
+----------+----------+----------+----------+----------+
|`group_name`|Name of the group to create|string||yes|
+----------+----------+----------+----------+----------+
|`tags`|Additional tags applied to all resources created|map(string)|empty map|no|
+----------+----------+----------+----------+----------+
