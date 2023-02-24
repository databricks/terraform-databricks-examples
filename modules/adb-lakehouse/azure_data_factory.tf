resource "azurerm_data_factory" "adf" {
  name                = var.data_factory_name
  location            = var.location
  resource_group_name = var.databricks_resource_group_name
  tags                = var.tags
  vsts_configuration {
    account_name    = var.adf_git_account_name
    branch_name     = var.adf_git_branch_name
    project_name    = var.adf_git_project_name
    repository_name = var.adf_git_repository_name
    root_folder     = var.adf_git_root_folder
    tenant_id       = var.adf_git_tenant_id
  }
  identity {
    type = "SystemAssigned"
  }
}