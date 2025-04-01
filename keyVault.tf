resource "random_password" "session_host_local" {
  length      = 20
  min_lower   = 1
  min_numeric = 1
  min_special = 1
  min_upper   = 1
}

module "keyVault" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = "0.10.0"

  name                = "kv-${var.org}-${var.env}-${local.reg}-01"
  location            = azurerm_resource_group.avd_rg.location
  resource_group_name = azurerm_resource_group.avd_rg.name

  tenant_id = data.azurerm_client_config.current.tenant_id

  role_assignments = {
    user_1 = {
      role_definition_id_or_name = "Key Vault Administrator"
      principal_id               = data.azurerm_client_config.current.object_id
      principal_type             = "User"
    }
  }

  network_acls = {
    bypass                     = "AzureServices"
    default_action             = "Deny"
    ip_rules                   = [data.http.runner_ip.response_body]
    virtual_network_subnet_ids = [data.azurerm_subnet.subnet.id]
  }

  secrets = {
    session_host_local_password = {
      name = local.session_host_local_password_secret_name
    }
  }
  secrets_value = {
    session_host_local_password = random_password.session_host_local.result
  }

  enable_telemetry = var.telemetry_enabled
}
