variable "location" {
  type        = string
  description = "(Required) The location for the resources in this module"
}

variable "hub_vnet_name" {
  type        = string
  description = "(Required) The name of the existing hub Virtual Network"
}

variable "hub_vnet_id" {
  type        = string
  description = "(Required) The name of the existing hub Virtual Network"
}

variable "hub_resource_group_name" {
  type        = string
  description = "(Required) The name of the existing Resource Group containing the hub Virtual Network"
}

variable "firewall_private_ip" {
  type        = string
  description = "(Required) The hub firewall's private IP address"
}

variable "spoke_resource_group_name" {
  type        = string
  description = "(Required) The name of the Resource Group to create"
}

variable "project_name" {
  type        = string
  description = "(Required) The name of the project associated with the infrastructure to be managed by Terraform"
}

variable "environment_name" {
  type        = string
  description = "(Required) The name of the project environment associated with the infrastructure to be managed by Terraform"
}

variable "spoke_vnet_address_space" {
  type        = string
  description = "(Required) The address space for the spoke Virtual Network"
}

variable "scc_relay_address_prefixes" {
  type        = list(string)
  description = "(Required) The IP address(es) of the Databricks SCC relay (see https://docs.microsoft.com/en-us/azure/databricks/administration-guide/cloud-configurations/azure/udr#control-plane-nat-and-webapp-ip-addresses)"
}

variable "privatelink_subnet_address_prefixes" {
  type        = list(string)
  description = "(Required) The address prefix(es) for the PrivateLink subnet"
}

variable "webapp_and_infra_routes" {
  type        = map(string)
  description = <<EOT
   (Required) Map of regional webapp and ext-infra CIDRs.
   Check https://docs.microsoft.com/en-us/azure/databricks/administration-guide/cloud-configurations/azure/udr#ip-addresses for more info
   Ex., for eastus:
   {
     "webapp1" : "40.70.58.221/32",
     "webapp2" : "20.42.4.209/32",
     "webapp3" : "20.42.4.211/32",
     "ext-infra" : "20.57.106.0/28"
   }
   EOT
}

variable "public_repos" {
  type        = list(string)
  description = "(Required) List of public repository IP addresses to allow access to."
}

variable "tags" {
  type        = map(string)
  description = "(Required) Map of tags to attach to resources"
}

variable "workspace_name" {
  type        = string
  description = "Name of Databricks workspace"
}

variable "data_factory_name" {
  type        = string
  description = "(Required) The name of the Azure Data Factory to deploy"
}

variable "key_vault_name" {
  type        = string
  description = "(Required) The name of the Azure Key Vault to deploy"
}

variable "databricks_resource_group_name" {
  type        = string
  description = "Name of resource group into which Databricks will be deployed"
}

variable "databricks_resource_group_id" {
  type        = string
  description = "Id of resource group into which Databricks will be deployed"
}

variable "location" {
  type        = string
  description = "Location in which Databricks will be deployed"
}

variable "vnet_id" {
  type        = string
  description = "ID of existing virtual network into which Databricks will be deployed"
}

variable "vnet_name" {
  type        = string
  description = "Name of existing virtual network into which Databricks will be deployed"
}

variable "nsg_id" {
  type        = string
  description = "ID of existing Network Security Group"
}

variable "route_table_id" {
  type        = string
  description = "ID of existing Route Table"
}

variable "private_subnet_address_prefixes" {
  type        = list(string)
  description = "Address space for private Databricks subnet"
}

variable "public_subnet_address_prefixes" {
  type        = list(string)
  description = "Address space for public Databricks subnet"
}

variable "storage_account_names" {
  type        = list(string)
  description = "Names of the different storage accounts"
}

variable "project_name" {
  type        = string
  description = "(Required) The name of the project associated with the infrastructure to be managed by Terraform"
}

variable "environment_name" {
  type        = string
  description = "(Required) The name of the project environment associated with the infrastructure to be managed by Terraform"
}

variable "tags" {
  type        = map(string)
  description = "Map of tags to attach to Databricks workspace"
}

variable "access_connector_id" {
  type        = string
  description = "The Databricks access connector ID"
}

variable "sp-digiplt-ucpipelines_id" {
  type        = string
  description = "The data pipeline service principale ID"
}

variable "autoloader_sp_id" {
  type        = string
  description = "The auto loader service principale ID"
}

variable "adf_git_account_name" {
  type        = string
  description = "The VSTS account name"
}

variable "adf_git_branch_name" {
  type        = string
  description = "The branch of the repository to get code from"
}

variable "adf_git_project_name" {
  type        = string
  description = "The name of the VSTS project"
}

variable "adf_git_repository_name" {
  type        = string
  description = "The name of the git repository"
}

variable "adf_git_root_folder" {
  type        = string
  description = "The  root folder within the repository. Set to / for the top level"
}

variable "adf_git_tenant_id" {
  type        = string
  description = "The Tenant ID associated with the VSTS account"
}

variable "key_vault_contributors" {
  type = map(object({
    id        = string
    object_id = string
  }))
  default     = {}
  description = "list of principals who can manage key vault"
}

#we will define it as an environment variable
variable "autoloader_secret" {
  type        = string
  description = "The secret of the autoloader service principal"
  default     = ""
}

variable "auditlog_categories" {
  type        = list(string)
  description = "Auditlog categories to collect from Databricks resource"
}
variable "auditlog_retention_days" {
  type        = string
  description = "Auditlog retention in days"
  default     = 2
}
