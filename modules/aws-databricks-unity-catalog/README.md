# Module aws-databricks-unity-catalog

## Description

This module creates a Databricks Unity Catalog Metastore and Storage Credential for said metastore. It automatically creates an IAM role suitable for Unity Catalog and attaches it to the newly created metastore.

## Required Providers

- `databricks` - only account-level providers are supported.
- `aws`
