resource "azurerm_databricks_workspace" "example" {
  name                = "${local.prefix}-workspace"
  resource_group_name = local.rg_name
  location            = local.rg_location
  sku                 = "premium"
  tags                = local.tags

  custom_parameters {
    virtual_network_id                                   = azurerm_virtual_network.this.id
    private_subnet_name                                  = azurerm_subnet.private.name
    public_subnet_name                                   = azurerm_subnet.public.name
    public_subnet_network_security_group_association_id  = azurerm_subnet_network_security_group_association.public.id
    private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.private.id
    storage_account_name                                 = local.dbfsname
  }
  # We need this, otherwise destroy doesn't cleanup things correctly
  depends_on = [
    azurerm_subnet_network_security_group_association.public,
    azurerm_subnet_network_security_group_association.private
  ]
}

module "auto_scaling_cluster_example" {
  source                  = "./modules/autoscaling_cluster"
  spark_version           = data.databricks_spark_version.latest_lts.id
  node_type_id            = var.node_type
  autotermination_minutes = var.global_auto_termination_minute
}
