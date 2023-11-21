# adb-overwatch-main-ws

This module either creates a new workspace, or uses an existing one to deploy **Overwatch** 

## Inputs

| Name           | Description                                                                                                                                                     | Type   | Default | Required |
|----------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------|--------|---------|----------|
|`subscription_id`| Azure subscription ID                                                                                                                                           | string ||yes|
|`rg_name`| Resource group name                                                                                                                                             | string ||yes|
|`overwatch_ws_name`| The name of an existing workspace, or the name to use to create a new one for Overwatch                                                                         | string ||yes|
|`use_existing_ws`| A boolean that determines to either use an existing Databricks workspace for Overwatch, when it is set to *true*, or create a new one when it is set to *false* | bool   ||yes|

## Ouputs

| Name           | Description           |
|----------------|-----------------------|
|`adb_ow_main_ws_url`| Overwatch workspace url |
|`latest_lts`| The latest DBR LTS version |