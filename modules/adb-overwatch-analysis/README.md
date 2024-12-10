# adb-overwatch-analysis

This module deploys the following Databricks [python notebooks](./notebooks) on an existing **Overwatch** workspace.
  ![Blank diagram](https://user-images.githubusercontent.com/103026825/233795155-566a9f1a-5ff2-4bfa-b940-4a4c5b898c6f.png)


## Inputs

| Name                                                                                      | Description                                  | Type     | Default | Required |
|-------------------------------------------------------------------------------------------|----------------------------------------------|----------|---------|:--------:|
| <a name="input_overwatch_ws_name"></a> [overwatch\_ws\_name](#input\_overwatch\_ws\_name) | The name of the Overwatch existing workspace | `string` | n/a     |   yes    |
| <a name="input_rg_name"></a> [rg\_name](#input\_rg\_name)                                 | Resource group name                          | `string` | n/a     |   yes    |
