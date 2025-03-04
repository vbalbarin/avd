# resource "time_rotating" "avd_token" {
#   rotation_days = 1
# }

# resource "random_string" "AVD_local_password" {
#   #count            = var.rdsh_count
#   length           = 16
#   special          = true
#   min_special      = 2
#   override_special = "*!@#?"
# }

locals {
  vm_name = "vm-avd-sh-"
}

module "avd_vm" {
  count  = var.rdsh_count
  source = "Azure/avm-res-compute-virtualmachine/azurerm"

  name                = "${local.vm_name}${count.index + 1}"
  resource_group_name = azurerm_resource_group.sessionhost_rg.name
  location            = azurerm_resource_group.sessionhost_rg.location
  version             = "0.18.0"
  provision_vm_agent  = true

  # Not sure why this condition is here?
  availability_set_resource_id = var.rdsh_count == 0 ? "" : azurerm_availability_set.avdset.id

  // TODO: Use Key Vault
  admin_password = "Password1234!"
  // admin_credential_key_vault_resource_id = module.avm_res_keyvault_vault.resource_id
  admin_username = "srvadmin"

  enable_telemetry                   = var.telemetry_enabled
  generate_admin_password_or_ssh_key = false

  os_type = "Windows"
  zone    = null

  sku_size = "Standard_D2as_v5"

  encryption_at_host_enabled = var.encryption_at_host_enabled

  // TODO: Re-enable?
  #   generated_secrets_key_vault_secret_config = {
  #     key_vault_resource_id = module.avm_res_keyvault_vault.resource_id
  #   }

  source_image_reference = {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "office-365"
    sku       = "win11-24h2-avd-m365"
    version   = "latest"
  }

  managed_identities = {
    # Required for Entra join
    system_assigned = true
    # For script download from blob
    user_assigned_resource_ids = [module.uami.resource.id]
  }

  network_interfaces = {
    "network_interface_${count.index + 1}" = {
      name = "${local.vm_name}${count.index + 1}_nic"
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
    # TODO: Extension names don't need the VM name in them
    # 1. Entra join the VM
    EntraJoin = {
      name                       = "${local.vm_name}${count.index + 1}-EntraJoin"
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
      name                       = "${local.vm_name}${count.index + 1}-AVD"
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
    FSLogixConfig = {
      name = "${local.vm_name}${count.index + 1}-FSLogix"
      # Use the custom script extension to configure FSLogix
      publisher                  = "Microsoft.Compute"
      type                       = "CustomScriptExtension"
      type_handler_version       = "1.10"
      auto_upgrade_minor_version = true

      protected_settings = jsonencode({
        commandToExecute = "powershell -ExecutionPolicy Unrestricted -File FSLogix.ps1 -StorageAccountConnectionString 'DefaultEndpointsProtocol=https;AccountName=${module.storage.resource.name};AccountKey=${module.storage.resource.primary_access_key}'"
      })

      settings = jsonencode({
        fileUris = [
          azurerm_storage_blob.fslogix_script.url
        ]
        managedIdentity = {
          objectId = module.uami.resource.principal_id
        }
      })
    }
  }
}

# Availability Set for VMs
resource "azurerm_availability_set" "avdset" {
  name                         = "avail-${var.org}-avd-sh-${var.env}-${local.reg}-01"
  resource_group_name          = azurerm_resource_group.sessionhost_rg.name
  location                     = azurerm_resource_group.sessionhost_rg.location
  platform_fault_domain_count  = 2
  platform_update_domain_count = 5
  managed                      = true
}
