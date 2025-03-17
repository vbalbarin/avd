module "st_naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.0"

  unique-length = 8
  suffix        = [var.org]
}

locals {
  container_name = "fslogix-script"
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

  #   azure_files_authentication = {
  #     directory_type                 = "AADKERB"
  #     default_share_level_permission = "StorageFileDataSmbShareContributor"
  #   }

  #   managed_identities = {
  #     system_assigned            = true
  #     user_assigned_resource_ids = [azurerm_user_assigned_identity.example_identity.id]
  #   }

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
