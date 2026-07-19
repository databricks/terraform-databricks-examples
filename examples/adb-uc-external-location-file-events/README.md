# Azure UC external location with managed file events

Provisions a Unity Catalog storage credential and external location with
**automatic managed AQS file events**, plus the documented Azure RBAC roles and
optional UC grants.

See the [module README](../../modules/adb-uc-external-location-file-events/README.md)
for RBAC details and [file arrival triggers](https://docs.databricks.com/aws/en/jobs/file-arrival-triggers).

## Prerequisites

- UC-enabled Azure Databricks workspace
- Existing ADLS Gen2 storage account and Access Connector
- `az login` (or Azure env credentials) with permission to assign RBAC
- Databricks CLI auth to the workspace (`databricks auth login --host ...`)

## Usage

1. Copy `terraform.tfvars.example` to `terraform.tfvars` and fill in values.
2. `terraform init`
3. `terraform plan`
4. `terraform apply`

## What gets created

- Storage credential (Azure managed identity via access connector)
- External location with `enable_file_events = true` and `file_event_queue.managed_aqs`
- Azure RBAC: Blob Data Contributor/Reader, Queue Data Contributor, Storage Account Contributor, EventGrid EventSubscription Contributor
- Optional UC grants on credential and location
