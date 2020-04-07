# module "caf_name_vm" {
#   source  = "aztfmod/caf-naming/azurerm"
#   version = "~> 0.1.0"
#   # source = "git://github.com/aztfmod/terraform-azurerm-caf-naming.git?ref=ll-fixes"
  
#   name    = var.name
#   type    = lower(var.os) == "linux" ? "vml" : "vmw"
#   convention  = var.convention
# }

resource "azurecaf_naming_convention" "vm_name" {
  name          = var.name
  prefix        = var.prefix
  resource_type = lower(var.os) == "linux" ? "vml" : "vmw"
  convention    = var.convention
}

# locals {
#   vm_name = lower(var.os) == "linux" ? module.caf_name_vm.vml :module.caf_name_vm.vmw
# }

resource "tls_private_key" "ssh" {
  count = lower(var.os) == "linux" ? 1 : 0

  algorithm   = "RSA"
  rsa_bits    = 4096
}

resource "azurerm_virtual_machine" "vm" {
  name                  = azurecaf_naming_convention.vm_name.result
  resource_group_name   = var.resource_group_name
  location              = var.location
  vm_size               = var.vm_size
  tags                  = local.tags
  network_interface_ids = var.network_interface_ids

  delete_os_disk_on_termination = true

  primary_network_interface_id = var.primary_network_interface_id

  os_profile {
    computer_name   = azurecaf_naming_convention.vm_name.result
    admin_username  = var.os_profile.admin_username 
    admin_password  = lookup(var.os_profile, "admin_password", null)
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
          key_data  = tls_private_key.ssh.0.public_key_openssh
      }
    }
  }

  dynamic "os_profile_windows_config" {

    for_each = lower(var.os) == "windows" ? [1] :[]

    content {
      provision_vm_agent        = lookup(var.os_profile, "provision_vm_agent", null)
      enable_automatic_upgrades = lookup(var.os_profile, "enable_automatic_upgrades", null)
      timezone                  = lookup(var.os_profile, "timezone", null)
      }
    }

  dynamic "os_profile_secrets" {

    for_each = var.os_profile_secrets == null ? [] : [1]

    content {
      source_vault_id           = var.os_profile_secrets.source_vault_id
      vault_certificates {
          certificate_url       = var.os_profile_secrets.vault_certificates.certificate_url
          certificate_store     = lookup(var.os_profile_secrets.vault_certificates,"certificate_store",null )
      }
    }
  }

  identity {
    type = "SystemAssigned"
  }

  license_type = lookup(var.os_profile, "license_type", null)

  provisioner "local-exec" {
    command = "az vm restart --name ${azurerm_virtual_machine.vm.name} --resource-group ${var.resource_group_name}"
  } 

}

# Store the SSH keys in the keyvault

resource "azurerm_key_vault_secret" "public_key_openssh" {
  count = lower(var.os) == "linux" ? 1 : 0

  name          = "${azurecaf_naming_convention.vm_name.result}-public-key-openssh"
  value         = base64encode(tls_private_key.ssh.0.public_key_openssh)
  key_vault_id  = var.key_vault_id

  lifecycle {
    ignore_changes = [
      key_vault_id
    ]
  }

}

resource "azurerm_key_vault_secret" "private_key_pem" {
  count = lower(var.os) == "linux" ? 1 : 0

  name          = "${azurecaf_naming_convention.vm_name.result}-private-key-openssh"
  value         = base64encode(tls_private_key.ssh.0.private_key_pem)
  key_vault_id  = var.key_vault_id

  lifecycle {
    ignore_changes = [
      key_vault_id
    ]
  }
  
}