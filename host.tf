resource "time_rotating" "avd_token" {
  rotation_days = 1
}

resource "random_string" "AVD_local_password" {
  count            = var.rdsh_count
  length           = 16
  special          = true
  min_special      = 2
  override_special = "*!@#?"
}



module "avd_vm" {
  count  = var.rdsh_count
  source = "Azure/avm-res-compute-virtualmachine/azurerm"


  name                         = "vm-avd-sh-${count.index + 1}"
  resource_group_name          = azurerm_resource_group.sessionhost_rg.name
  location                     = azurerm_resource_group.sessionhost_rg.location
  version                      = "0.18.0"
  provision_vm_agent           = true
  availability_set_resource_id = var.rdsh_count == 0 ? "" : azurerm_availability_set.avdset.id

  // TODO: Use Key Vault
  admin_password = "Password1234!"
  // admin_credential_key_vault_resource_id = module.avm_res_keyvault_vault.resource_id
  admin_username = "srvadmin"


  enable_telemetry                   = var.telemetry_enabled
  generate_admin_password_or_ssh_key = false

  os_type = "Windows"
  zone    = null
  // Must use a SKU with a local temp disk because the data disk is expected to be "Disk2" (// TODO: confirm)
  sku_size = "Standard_D2ads_v5"

  encryption_at_host_enabled = true

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
    system_assigned = true
  }

  network_interfaces = {
    "network_interface_${count.index + 1}" = {
      name = "nic-${count.index + 1}"
      ip_configurations = {
        ipconfig_1 = {
          name                          = "nic${count.index + 1}_config"
          private_ip_subnet_resource_id = data.azurerm_subnet.subnet.id
          private_ip_address_allocation = "Dynamic"
        }
      }
    }
  }

  license_type = "Windows_Client"
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
