resource "azurerm_network_interface" "splunk-nic" {
  name                = "splunk-nic"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.splunksubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.splunk-nic-pubip.id
  }
}

resource "tls_private_key" "splunk_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content         = tls_private_key.splunk_ssh.private_key_pem
  filename        = "ssh_private.pem"
  file_permission = "0600"
}

resource "azurerm_public_ip" "splunk-nic-pubip" {
  name                = "splunk-nic-pubip"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  allocation_method   = "Static"
}

resource "azurerm_linux_virtual_machine" "example" {
  name                = "splunk-vm"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  size                = "Standard_DS4_v2"
  admin_username      = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.splunk-nic.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.splunk_ssh.public_key_openssh // using generated ssh key
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
    local_file.setupscript,
    module.adls_content,
    azurerm_storage_blob.splunk_setup_file,
    azurerm_storage_blob.splunk_databricks_app_file
  ]
}

resource "azurerm_virtual_machine_extension" "splunksetupagent" {
  name                 = "hwangagent"
  virtual_machine_id   = azurerm_linux_virtual_machine.example.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"

  settings = <<SETTINGS
  {
    "fileUris": ["https://${module.adls_content.storage_name}.blob.core.windows.net/${module.adls_content.container_name}/splunk_setup.sh"],
    "commandToExecute": "sudo sh splunk_setup.sh"
  }
  SETTINGS

  depends_on = [
    azurerm_linux_virtual_machine.example,
    azurerm_storage_blob.splunk_setup_file,
    azurerm_storage_blob.splunk_databricks_app_file
  ]
}
