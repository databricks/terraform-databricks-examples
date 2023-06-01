# versions.tf
terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = ">=1.14"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.54.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

# using azure cli auth for databricks provider
provider "databricks" {
  host = var.workspace_url
}

locals {
  db_url = "jdbc:sqlserver://${var.metastoreserver}.database.windows.net:1433;database=${var.metastoredbname};user=${var.db_username}@${var.metastoreserver};password={${var.db_password}};encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;"
}
