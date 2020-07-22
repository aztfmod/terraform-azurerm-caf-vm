# Deploys an Azure Virtual Machine
Creates an Azure Virtual Machine.
This virtual machine can be created from:
- Azure Gallery
- Azure Shared Image

Reference the module to a specific version (recommended):
```hcl
module "vm" {
  source  = "aztfmod/caf-vm/azurerm"
  version = "0.x.y"
  
  prefix                        = var.prefix
  convention                    = var.convention
  name                          = var.name
  resource_group_name           = var.resource_group
  location                      = var.location 
  tags                          = var.tags
  network_interface_ids         = var.network_interface_ids
  primary_network_interface_id  = var.primary_network_interface_id
  os                            = var.os
  os_profile                    = var.os_profile
  storage_image_reference       = var.storage_image_reference
  storage_os_disk               = var.storage_os_disk
  vm_size                       = var.vm_size
}
```

## Inputs

| Name | Type | Default | Description | 
| -- | -- | -- | -- |
| prefix | string | None | Prefix to be used. |
| convention | string | None | Naming convention to be used (check at the naming convention module for possible values).  | 
| name | string | None | Specifies the name of the VM. Changing this forces a new resource to be created. |
| resource_group_name | string | None | The name of the resource group in which to create the VM. Changing this forces a new resource to be created. |
| location | string | None | Specifies the supported Azure location where to create the resource. Changing this forces a new resource to be created.  |
| tags | map | None | Map of tags for the deployment.  | 
| la_workspace_id | string | None | Log Analytics Repository ID. | 
| network_interface_ids | list | False |  A list of Network Interface ID's which should be associated with the Virtual Machine | 
| primary_network_interface_id | string | None | The primary Network Interface ID's which should be associated with the Virtual Machine. Note when using multiple NICs you must set it in the nic_object configuration | 
| os | string | Windows |Define if the operating system is 'Linux' or 'Windows'  | 
| os_profile | object | None | A windows or Linux profile as per documentation. To find types of images, refer to https://docs.microsoft.com/en-us/azure/virtual-machines/windows/cli-ps-findimage | 
| os_profile_secrets | object | None | Specifies the settings to store OS secret as defined in https://www.terraform.io/docs/providers/azurerm/r/virtual_machine.html | 
| storage_image_reference | string | None | storage_image_reference  | 
| storage_os_disk | object | null | storage_os_disk  | 
| vm_size | string | None | Azure VM size name, to list all images available in a regionm use : "az vm list-sizes --location <region>" | 
| availability_set_id | string | null | A resource id of availability set to use  |


## Output

| Name | Type | Description | 
| -- | -- | -- | 
| network_interface_ids | list(string) | Set of all NIC identifers |
| primary_network_interface_id | string | Primary NIC ID |
| admin_username | string | Name of the local admin account created | 
| ssh_private_key_pem | string | Private Key of the VM | 
| msi_system_principal_id | string | Principal ID for the created VM | 
| id | string | Identifier of the VM |
| name | string | Name of the VM | 
