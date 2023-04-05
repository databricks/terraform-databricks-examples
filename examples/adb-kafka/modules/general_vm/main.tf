resource "azurerm_network_interface" "general-nic" {
  name                = "${var.vm_name}-nic"
  location            = var.region
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.general-nic-pubip.id
  }
}

resource "tls_private_key" "general_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content         = tls_private_key.general_ssh.private_key_pem
  filename        = "${var.vm_name}_ssh_private.pem"
  file_permission = "0600"
}

resource "azurerm_public_ip" "general-nic-pubip" {
  name                = "${var.vm_name}-nic-pubip"
  resource_group_name = var.resource_group_name
  location            = var.region
  allocation_method   = "Static"
}

resource "azurerm_linux_virtual_machine" "general_vm" {
  name                = "${var.vm_name}-vm"
  resource_group_name = var.resource_group_name
  location            = var.region
  size                = "Standard_D16s_v3"
  admin_username      = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.general-nic.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.general_ssh.public_key_openssh // using generated ssh key
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

resource "azurerm_managed_disk" "general_disk" {
  name                 = "${var.vm_name}-disk"
  location             = var.region
  resource_group_name  = var.resource_group_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 60
}

resource "azurerm_virtual_machine_data_disk_attachment" "diskattachment" {
  managed_disk_id    = azurerm_managed_disk.general_disk.id
  virtual_machine_id = azurerm_linux_virtual_machine.general_vm.id
  lun                = "10"
  caching            = "ReadWrite"
}
