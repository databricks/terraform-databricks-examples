# adb-overwatch-analysis

This module deploys the following Databricks [python notebooks](./notebooks) on an existing **Overwatch** workspace.
  ![Blank diagram](https://user-images.githubusercontent.com/103026825/233795155-566a9f1a-5ff2-4bfa-b940-4a4c5b898c6f.png)


## Inputs

| Name           | Description                          | Type   | Default | Required |
|----------------|--------------------------------------|--------|---------|----------|
|`rg_name`|Resource group name|string||yes|
|`overwatch_ws_name`|Overwatch existing workspace name|string||yes|
