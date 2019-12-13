resource "tls_private_key" "ssh" {
  algorithm   = "RSA"
  rsa_bits    = 4096
}


resource "azurerm_virtual_machine" "vm" {
  name                  = var.name
  resource_group_name   = var.resource_group_name
  location              = var.location
  vm_size               = var.vm_size
  network_interface_ids = var.network_interface_ids

  delete_os_disk_on_termination = true

  primary_network_interface_id = var.primary_network_interface_id

  os_profile {
    computer_name   = var.os_profile.computer_name
    admin_username  = var.os_profile.admin_username 
  }

  // Reference a marketplace image
  dynamic "storage_image_reference" {
    for_each = lookup(var.storage_image_reference, "id", null) == null ? [1] : []

    content {
      publisher = var.storage_image_reference.publisher
      offer     = var.storage_image_reference.offer
      sku       = var.storage_image_reference.sku
      version   = var.storage_image_reference.version
    }
  }

  // Reference an image gallery ID
  dynamic "storage_image_reference" {
    for_each = lookup(var.storage_image_reference, "id", null) == null ? [] : [1]

    content {
      id   = var.storage_image_reference.id
    }
  }

  dynamic "storage_os_disk" {

    for_each = var.storage_os_disk == null ? [] : [1]

    content {
      name                      = var.storage_os_disk.name
      managed_disk_type         = var.storage_os_disk.managed_disk_type
      caching                   = var.storage_os_disk.caching
      create_option             = var.storage_os_disk.create_option
      disk_size_gb              = var.storage_os_disk.disk_size_gb
      write_accelerator_enabled = lookup(var.storage_os_disk, "write_accelerator_enabled", null)
    }
  }

  dynamic "os_profile_linux_config" {

    for_each = lower(var.os) == "linux" ? [1] :[]

    content {
      disable_password_authentication = true

      // TODO: ssh key management to be in external module
      ssh_keys {
          path  = "/home/${var.os_profile.admin_username}/.ssh/authorized_keys"
          key_data  = tls_private_key.ssh.public_key_openssh
      }
    }
  }

  identity {
    type = "SystemAssigned"
  }

  provisioner "local-exec" {
    command = "az vm restart --name ${azurerm_virtual_machine.vm.name} --resource-group ${var.resource_group_name}"
  } 

}