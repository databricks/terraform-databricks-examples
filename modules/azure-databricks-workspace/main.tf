/**
 * Azure Databricks workspace in custom VNet
 *
 * Module creates:
 * * Resource group with random prefix
 * * Tags, including `Owner`, which is taken from `az account show --query user`
 * * VNet with public and private subnet
 * * Databricks workspace
 */
