locals {
  vm_name = var.vm_name_prefix

  # Create a VM map to avoid repeating the VM name each time
  vm_map = {
    for i in range(var.rdsh_count) : i => {
      name = "${local.vm_name}${i + 1}"
    }
  }
}

module "avd_vm" {
  for_each = local.vm_map

  source  = "Azure/avm-res-compute-virtualmachine/azurerm"
  version = "0.18.1"

  name                = each.value.name
  resource_group_name = module.sessionhost_rg.resource.name
  location            = module.sessionhost_rg.resource.location
  provision_vm_agent  = true

  availability_set_resource_id = azurerm_availability_set.avdset.id

  admin_username                     = var.session_host_admin_username
  admin_password                     = random_password.session_host_local.result
  generate_admin_password_or_ssh_key = false

  enable_telemetry = var.telemetry_enabled

  os_type = "Windows"
  zone    = null

  sku_size = var.session_host_sku_size

  secure_boot_enabled = true
  vtpm_enabled        = true

  encryption_at_host_enabled = var.encryption_at_host_enabled

  source_image_reference = var.session_host_source_image_reference

  managed_identities = {
    # Required for Entra join
    system_assigned = true
    # For script download from blob
    user_assigned_resource_ids = [module.uami.resource.id]
  }

  network_interfaces = {
    "network_interface_1" = {
      name = "${each.value.name}_nic"
      ip_configurations = {
        ipconfig_1 = {
          name                          = "ipconfig_1"
          private_ip_subnet_resource_id = data.azurerm_subnet.subnet.id
          private_ip_address_allocation = "Dynamic"
        }
      }
    }
  }

  license_type = "Windows_Client"

  extensions = {
    # 1. Entra join the VM
    EntraJoin = {
      name                       = "EntraJoin"
      publisher                  = "Microsoft.Azure.ActiveDirectory"
      type                       = "AADLoginForWindows"
      type_handler_version       = "2.2"
      auto_upgrade_minor_version = true

      settings = var.enroll_in_intune ? jsonencode({
        mdmId = "0000000a-0000-0000-c000-000000000000"
      }) : null

      deploy_sequence = 1
    },
    # 2. Install the AVD agent, join to host pool
    AVD = {
      name                       = "SessionHostConfiguration"
      publisher                  = "Microsoft.PowerShell"
      type                       = "DSC"
      type_handler_version       = "2.83"
      auto_upgrade_minor_version = true

      protected_settings = jsonencode({
        properties = {
          registrationInfoToken = azurerm_virtual_desktop_host_pool_registration_info.registrationInfo.token
        }
      })
      settings = jsonencode({
        modulesUrl            = "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_1.0.02929.635.zip"
        configurationFunction = "Configuration.ps1\\AddSessionHost"
        properties = {
          HostPoolName = module.hostpool.resource.name
        }
      })

      deploy_sequence = 2
    },
    # 3+. FSLogix customization
    # TODO: Include PowerSTIG prep here (single Custom Script Extension only)
    CSE = {
      name = "CustomScript"
      # Use the custom script extension to configure FSLogix
      publisher                  = "Microsoft.Compute"
      type                       = "CustomScriptExtension"
      type_handler_version       = "1.10"
      auto_upgrade_minor_version = true

      protected_settings = jsonencode({
        commandToExecute = "powershell -ExecutionPolicy Unrestricted -File Set-FSLogixConfiguration.ps1 -LocalUserAccountName ${var.session_host_admin_username} -StorageAccountConnectionString DefaultEndpointsProtocol=https;AccountName=${module.storage.resource.name};AccountKey=${module.storage.resource.primary_access_key}"
        managedIdentity = {
          objectId = module.uami.resource.principal_id
        }
      })

      settings = jsonencode({
        fileUris = [
          azurerm_storage_blob.fslogix_script.url
          # Alternate location
          #"https://gist.githubusercontent.com/SvenAelterman/dcc5a5df64f3dfe6bfa51efd33de45f5/raw/fabc89c14adb44ec36472574b09e1615332089aa/Set-FSLogixConfiguration.ps1"
        ]
      })
    }
  }

  depends_on = [module.keyVault]
}

# Add two more custom script extensions to configure PowerSTIG, if needed
# resource "azurerm_virtual_machine_extension" "powerstig_prep" {
#   count                      = var.powerstig_enabled ? var.rdsh_count : 0
#   name                       = "CustomScript"
#   virtual_machine_id         = module.avd_vm[count.index].resource_id
#   publisher                  = "Microsoft.Compute"
#   type                       = "CustomScriptExtension"
#   type_handler_version       = "1.10"
#   auto_upgrade_minor_version = true

#   protected_settings = jsonencode({
#     commandToExecute = "powershell -ExecutionPolicy Unrestricted -File InstallModules.ps1 -autoInstallDependencies $true"
#   })

#   settings = jsonencode({
#     fileUris = [
#       azurerm_storage_blob.powerstig_script_RequiredModules.url,
#       azurerm_storage_blob.powerstig_script_GenerateStigChecklist.url,
#       azurerm_storage_blob.powerstig_script_InstallModules.url
#       # Alternate locations (unmodified)
#       # https://raw.githubusercontent.com/Azure/ato-toolkit/refs/heads/master/stig/windows/GenerateStigChecklist.ps1,
#       # https://raw.githubusercontent.com/Azure/ato-toolkit/refs/heads/master/stig/windows/InstallModules.ps1,
#       # https://raw.githubusercontent.com/Azure/ato-toolkit/refs/heads/master/stig/windows/RequiredModules.ps1
#     ]
#   })
# }

# resource "azurerm_virtual_machine_extension" "powerstig" {
#   count                      = var.powerstig_enabled ? var.rdsh_count : 0
#   name                       = "PowerSTIG"
#   virtual_machine_id         = module.avd_vm[count.index].resource_id
#   publisher                  = "Microsoft.PowerShell"
#   type                       = "DSC"
#   type_handler_version       = "2.83"
#   auto_upgrade_minor_version = true

#   settings = jsonencode({
#     wmfVersion = "latest"
#     configuration = {
#       url = azurerm_storage_blob.powerstig_dsc_zip.url
#       # Alternate URL
#       # https://raw.githubusercontent.com/Azure/ato-toolkit/refs/heads/master/stig/windows/Windows.ps1.zip
#       script   = "Windows.ps1"
#       function = "Windows"
#     }
#   })

#   depends_on = [azurerm_virtual_machine_extension.powerstig_prep]
# }

# Availability Set for VMs
resource "azurerm_availability_set" "avdset" {
  name                         = "avail-${var.org}-avd-sh-${var.env}-${local.reg}-01"
  resource_group_name          = module.sessionhost_rg.resource.name
  location                     = module.sessionhost_rg.resource.location
  platform_fault_domain_count  = 2
  platform_update_domain_count = 5
  managed                      = true
}
