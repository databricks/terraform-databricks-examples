source "azure-arm" "my-example" {
  subscription_id = "${var.subscription_id}"

  # Managed Image, saving generated image to rg
  managed_image_resource_group_name = var.managed_img_rg_name
  managed_image_name = var.managed_img_name

  os_type = "Linux"
  image_publisher = "Canonical"
  image_offer = "UbuntuServer"
  image_sku = "18.04-LTS"

  location = "Southeast Asia"
  vm_size = "Standard_DS2_v2"

  azure_tags = {
    dept = "hwangtest"
  }
}

build {
  sources = ["sources.azure-arm.my-example"]

  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo {{ .Path }}"
    script          = "../scripts/setup.sh"
  }
}