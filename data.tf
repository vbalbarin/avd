# Get network vnet data
data "azurerm_virtual_network" "vnet" {
  name                = local.vnet
  resource_group_name = local.vnet_rg
  provider            = azurerm.spoke

}

# Get network subnet data
data "azurerm_subnet" "subnet" {
  name                 = local.snet
  resource_group_name  = local.vnet_rg
  virtual_network_name = local.vnet
  provider             = azurerm.spoke
}

data "azurerm_client_config" "current" {}

data "azurerm_role_definition" "rbac_storage_blob_data_reader" {
  name = "Storage Blob Data Reader"
}

data "http" "runner_ip" {
  url = "https://ipecho.net/plain"
}
