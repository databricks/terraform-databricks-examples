# adb-uc-external-location-file-events

Creates Azure Unity Catalog **storage credentials** and **external locations** with
[managed file events](https://learn.microsoft.com/en-us/azure/databricks/connect/unity-catalog/cloud-storage/manage-external-locations)
enabled via Azure Queue Storage (managed AQS). Also assigns the documented Azure RBAC roles
required for data access and automatic file-event setup.

This is useful for [file arrival triggers](https://docs.databricks.com/aws/en/jobs/file-arrival-triggers)
and other ingestion patterns that benefit from cloud storage change notifications.

## Prerequisites

- Unity Catalog–enabled Azure Databricks workspace
- Existing Azure Data Lake Storage Gen2 account + container path
- Existing [Access Connector for Azure Databricks](https://learn.microsoft.com/en-us/azure/databricks/connect/unity-catalog/cloud-storage/azure-managed-identities)
- Permission to assign Azure RBAC on the storage account and its resource group
- Permission to create UC storage credentials and external locations

## Azure RBAC (automatic managed file events)

When `assign_azure_rbac = true` (default), the access connector managed identity receives:

| Scope | Role | Purpose |
| ----- | ---- | ------- |
| Storage account | `Storage Blob Data Contributor` (or `Reader` if all locations are `read_only`) | Data plane access |
| Storage account | `Storage Queue Data Contributor` | Subscribe to file-change notifications |
| Storage account | `Storage Account Contributor` | Let Databricks auto-create the queue / routing |
| Resource group | `EventGrid EventSubscription Contributor` | Let Databricks auto-create Event Grid subscriptions |

`Storage Account Contributor` and the Event Grid role are only needed for **automatic** file-event
setup. Manual / provided-queue configuration can omit them but is unsupported by Databricks.

## Example

```hcl
module "uc_locations" {
  source = "../../modules/adb-uc-external-location-file-events"

  name_prefix          = "demo"
  access_connector_id  = "/subscriptions/.../accessConnectors/uc-access-connector"
  storage_account_id   = "/subscriptions/.../storageAccounts/stdemo"
  resource_group_name  = "rg-demo"

  external_locations = [
    {
      name    = "demo-landing"
      url     = "abfss://landing@stdemo.dfs.core.windows.net/incoming"
      comment = "Landing zone with file events"
    }
  ]

  credential_grants = [
    {
      principal  = "data-engineers"
      privileges = ["CREATE_EXTERNAL_LOCATION", "READ_FILES", "WRITE_FILES"]
    }
  ]

  location_grants = [
    {
      principal  = "data-engineers"
      privileges = ["BROWSE", "READ_FILES", "WRITE_FILES", "CREATE_EXTERNAL_TABLE", "CREATE_EXTERNAL_VOLUME"]
    }
  ]
}
```

See also [examples/adb-uc-external-location-file-events](../../examples/adb-uc-external-location-file-events).

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.0.0 |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | >= 1.50.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.0.0 |
| <a name="provider_databricks"></a> [databricks](#provider\_databricks) | >= 1.50.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [azurerm_role_assignment.blob_data](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.eventgrid_subscription](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.queue_data](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.storage_account_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [databricks_external_location.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/external_location) | resource |
| [databricks_grants.credential](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/grants) | resource |
| [databricks_grants.location](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/grants) | resource |
| [databricks_storage_credential.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/storage_credential) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_databricks_access_connector.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/databricks_access_connector) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_access_connector_id"></a> [access\_connector\_id](#input\_access\_connector\_id) | Azure resource ID of the Access Connector for Azure Databricks (managed identity used by the storage credential) | `string` | n/a | yes |
| <a name="input_external_locations"></a> [external\_locations](#input\_external\_locations) | External locations to create. Each location gets managed AQS file events enabled. | <pre>list(object({<br/>    name      = string<br/>    url       = string<br/>    comment   = optional(string, "Managed by Terraform")<br/>    read_only = optional(bool, false)<br/>  }))</pre> | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix used for storage credential and external location names | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group that contains the storage account (used for managed AQS and Event Grid RBAC) | `string` | n/a | yes |
| <a name="input_storage_account_id"></a> [storage\_account\_id](#input\_storage\_account\_id) | Azure resource ID of the ADLS Gen2 storage account that backs the external location(s) | `string` | n/a | yes |
| <a name="input_assign_azure_rbac"></a> [assign\_azure\_rbac](#input\_assign\_azure\_rbac) | Assign the documented Azure RBAC roles required for data access and automatic managed file events | `bool` | `true` | no |
| <a name="input_create_storage_credential"></a> [create\_storage\_credential](#input\_create\_storage\_credential) | When true, create a storage credential backed by the access connector. When false, use existing\_credential\_name. | `bool` | `true` | no |
| <a name="input_credential_grants"></a> [credential\_grants](#input\_credential\_grants) | UC grants on the storage credential. Defaults to empty (owner-only). | <pre>list(object({<br/>    principal  = string<br/>    privileges = list(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_existing_credential_name"></a> [existing\_credential\_name](#input\_existing\_credential\_name) | Name of an existing storage credential to reuse when create\_storage\_credential is false | `string` | `""` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | Force destroy UC objects even if dependents exist | `bool` | `true` | no |
| <a name="input_location_grants"></a> [location\_grants](#input\_location\_grants) | UC grants applied to every external location.<br/>Recommended privileges for data engineers: BROWSE, READ\_FILES, WRITE\_FILES,<br/>CREATE\_EXTERNAL\_TABLE, CREATE\_EXTERNAL\_VOLUME. | <pre>list(object({<br/>    principal  = string<br/>    privileges = list(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_storage_credential_name"></a> [storage\_credential\_name](#input\_storage\_credential\_name) | Name for the created storage credential. Defaults to "<name\_prefix>-storage-credential". | `string` | `""` | no |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Azure subscription ID for managed AQS file-event configuration. Defaults to the current azurerm client subscription when empty. | `string` | `""` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_azure_rbac_roles"></a> [azure\_rbac\_roles](#output\_azure\_rbac\_roles) | Azure RBAC roles assigned to the access connector managed identity when assign\_azure\_rbac is true |
| <a name="output_external_location_ids"></a> [external\_location\_ids](#output\_external\_location\_ids) | Map of external location name to ID |
| <a name="output_external_location_names"></a> [external\_location\_names](#output\_external\_location\_names) | Names of the created external locations |
| <a name="output_external_location_urls"></a> [external\_location\_urls](#output\_external\_location\_urls) | Map of external location name to URL |
| <a name="output_storage_credential_id"></a> [storage\_credential\_id](#output\_storage\_credential\_id) | ID of the created storage credential (null when reusing an existing credential) |
| <a name="output_storage_credential_name"></a> [storage\_credential\_name](#output\_storage\_credential\_name) | Name of the storage credential used by the external locations |
<!-- END_TF_DOCS -->
