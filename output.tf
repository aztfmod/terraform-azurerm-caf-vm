output "network_interface_ids" {
    depends_on = [azurerm_virtual_machine.vm]
    value = azurerm_virtual_machine.vm.network_interface_ids
}

output "primary_network_interface_id" {
    depends_on = [azurerm_virtual_machine.vm]
    value = azurerm_virtual_machine.vm.primary_network_interface_id
}

output "admin_username" {
    depends_on = [azurerm_virtual_machine.vm]
    value = var.os_profile.admin_username
}

output "ssh_private_key_pem_secret_id" {
    count = lower(var.os) == "linux" ? 1 : 0
    # sensitive = true
    description = "Map of keyvault_id and secret Id of the ssh_private_key_pem. The ssh_private_key_pem is base64encoded"
    value = {
        "keyvault_id"           = var.keyvault_id,
        "ssh_private_key_pem"   = azurerm_key_vault_secret.private_key_pem.0.id
    }
}

output "msi_system_principal_id" {
    value = azurerm_virtual_machine.vm.identity.0.principal_id
}

output "name" {
  value = azurerm_virtual_machine.vm.name
}

output "id" {
  value = azurerm_virtual_machine.vm.id
}

output "object" {
    sensitive = true
    value = azurerm_virtual_machine.vm.id
}
