# GCP Databricks Workspace Composer

This module creates a complete Databricks workspace on Google Cloud Platform with full networking, connectivity, and authentication management.

## Usage

See the examples in `tests/` for common scenarios.

## Components

- **network**: VPC creation or integration (databricks_managed, create, or existing)
- **private_connectivity**: Private Service Connect (PSC) with optional frontend/backend
- **account**: Databricks MWS resources and workspace
- **dns**: Private DNS zones for restricted egress scenarios
