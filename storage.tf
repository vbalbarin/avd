module "st_naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.0"

  unique-length = 8
  suffix        = [var.org]
}

locals {
  container_name           = "fslogix-script"
  powerstig_container_name = "powerstig-scripts"
}
module "storage" {
  source = "Azure/avm-res-storage-storageaccount/azurerm"

  account_replication_type        = "LRS"
  account_tier                    = "Standard"
  account_kind                    = "StorageV2"
  location                        = azurerm_resource_group.avd_rg.location
  name                            = module.st_naming.storage_account.name_unique
  resource_group_name             = azurerm_resource_group.avd_rg.name
  min_tls_version                 = "TLS1_2"
  shared_access_key_enabled       = true
  public_network_access_enabled   = true
  default_to_oauth_authentication = true
  large_file_share_enabled        = true

  # TODO: Default to true
  infrastructure_encryption_enabled = false

  role_assignments = {
    uami = {
      role_definition_id_or_name       = data.azurerm_role_definition.rbac_storage_blob_data_reader.name
      principal_id                     = module.uami.resource.principal_id
      principal_type                   = "ServicePrincipal"
      skip_service_principal_aad_check = true
    }
    user_1 = {
      role_definition_id_or_name = "Storage Blob Data Contributor"
      principal_id               = data.azurerm_client_config.current.object_id
      principal_type             = "User"
    }
  }

  network_rules = {
    bypass                     = ["AzureServices"]
    default_action             = "Deny"
    ip_rules                   = [data.http.runner_ip.response_body]
    virtual_network_subnet_ids = toset([data.azurerm_subnet.subnet.id])
  }

  containers = {
    FSLogixScript = {
      name = local.container_name
    }
    PowerSTIGSCript = {
      name = local.powerstig_container_name
    }
  }

  enable_telemetry = var.telemetry_enabled
}

// Upload the FSLogix configuration script to the blob container
resource "azurerm_storage_blob" "fslogix_script" {
  name                   = "Set-FSLogixConfiguration.ps1"
  storage_account_name   = module.storage.name
  storage_container_name = local.container_name
  type                   = "Block"
  source                 = "scripts/FSLogix/1.0.0/Set-FSLogixConfiguration.ps1"
  content_type           = "application/x-powershell"
}

# Upload the PowerSTIG scripts to the blob container
resource "azurerm_storage_blob" "powerstig_script_RequiredModules" {
  name                   = "RequiredModules.ps1"
  storage_account_name   = module.storage.name
  storage_container_name = local.powerstig_container_name
  type                   = "Block"
  source                 = "scripts/PowerSTIG/0.0.1/RequiredModules.ps1"
  content_type           = "application/x-powershell"
}

resource "azurerm_storage_blob" "powerstig_script_GenerateStigChecklist" {
  name                   = "GenerateStigChecklist.ps1"
  storage_account_name   = module.storage.name
  storage_container_name = local.powerstig_container_name
  type                   = "Block"
  source                 = "scripts/PowerSTIG/0.0.1/GenerateStigChecklist.ps1"
  content_type           = "application/x-powershell"
}

resource "azurerm_storage_blob" "powerstig_script_InstallModules" {
  name                   = "InstallModules.ps1"
  storage_account_name   = module.storage.name
  storage_container_name = local.powerstig_container_name
  type                   = "Block"
  source                 = "scripts/PowerSTIG/0.0.1/InstallModules.ps1"
  content_type           = "application/x-powershell"
}

resource "azurerm_storage_blob" "powerstig_dsc_zip" {
  name                   = "Windows.ps1.zip"
  storage_account_name   = module.storage.name
  storage_container_name = local.powerstig_container_name
  type                   = "Block"
  source                 = "scripts/PowerSTIG/0.0.1/Windows.ps1.zip"
  content_type           = "application/x-zip-compressed"
}
