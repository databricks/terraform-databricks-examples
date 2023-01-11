resource "azurerm_network_interface" "teradata-nic" {
  name                = "${var.naming_prefix}-teradatanic"
  location            = var.region
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.teradata-nic-pubip.id
  }
}

resource "tls_private_key" "teradata_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content         = tls_private_key.teradata_ssh.private_key_pem
  filename        = "ssh_private.pem"
  file_permission = "0600"
}

resource "azurerm_public_ip" "teradata-nic-pubip" {
  name                = "teradata-nic-pubip"
  resource_group_name = var.resource_group_name
  location            = var.region
  allocation_method   = "Static"
}

resource "azurerm_linux_virtual_machine" "teradatavm" {
  name                = "teradata-vm"
  resource_group_name = var.resource_group_name
  location            = var.region
  size                = "Standard_D16s_v3"
  admin_username      = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.teradata-nic.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.teradata_ssh.public_key_openssh // using generated ssh key
    # public_key = file("/home/azureuser/.ssh/authorized_keys") //using existing ssh key 
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  depends_on = [
    local_file.private_key,
  ]
}

resource "azurerm_managed_disk" "teradatadisk" {
  name                 = "${var.naming_prefix}-disk1"
  location             = var.region
  resource_group_name  = var.resource_group_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 60
}

resource "azurerm_virtual_machine_data_disk_attachment" "diskattachment" {
  managed_disk_id    = azurerm_managed_disk.teradatadisk.id
  virtual_machine_id = azurerm_linux_virtual_machine.teradatavm.id
  lun                = "10"
  caching            = "ReadWrite"
}

/*
resource "azurerm_virtual_machine_extension" "teradatasetupagent" {
  name                 = "hwangagent"
  virtual_machine_id   = azurerm_linux_virtual_machine.example.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"

  settings = <<SETTINGS
  {
    "fileUris": ["https://${module.adls_content.storage_name}.blob.core.windows.net/${module.adls_content.container_name}/teradata_setup.sh"],
    "commandToExecute": "sudo sh teradata_setup.sh"
  }
  SETTINGS

  depends_on = [
    azurerm_linux_virtual_machine.example,
    azurerm_storage_blob.teradata_setup_file,
    azurerm_storage_blob.teradata_databricks_app_file
  ]
}
*/
