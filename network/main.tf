module "subnet_addrs" {
  source = "hashicorp/subnets/cidr"

  base_cidr_block = local.conf_network_resources.vnet_address_space
  networks = [
    {
      name     = "AzureFirewallSubnet"
      new_bits = 3
    },
    {
      name     = "AzureFirewallManagementSubnet"
      new_bits = 3
    },
    {
      name     = "AzureBastionSubnet"
      new_bits = 3
    },
    {
      name     = "PrivateEndpointSubnet"
      new_bits = 4
    },
    {
      name     = "AVDSubnet"
      new_bits = 1
    },
  ]
}

module "virtualnetwork" {
  source = "Azure/avm-res-network-virtualnetwork/azurerm"

  // DO NOT SET DNS IPs HERE

  name                = "vnet-${var.org}-avd-${var.env}-${local.conf_network_resources.reg}-01"
  resource_group_name = azurerm_resource_group.network_rg.name
  location            = azurerm_resource_group.network_rg.location

  address_space = [local.conf_network_resources.vnet_address_space, ]
  subnets = {
    "AzureFirewallSubnet" = {
      name             = "AzureFirewallSubnet"
      address_prefixes = [module.subnet_addrs.network_cidr_blocks["AzureFirewallSubnet"]]
    }
    "AzureFirewallManagementSubnet" = {
      name             = "AzureFirewallManagementSubnet"
      address_prefixes = [module.subnet_addrs.network_cidr_blocks["AzureFirewallManagementSubnet"]]
    }
    "AzureBastionSubnet" = {
      name             = "AzureBastionSubnet"
      address_prefixes = [module.subnet_addrs.network_cidr_blocks["AzureBastionSubnet"]]
    }
    "PrivateEndpointSubnet" = {
      name                              = "PrivateEndpointSubnet"
      address_prefixes                  = [module.subnet_addrs.network_cidr_blocks["PrivateEndpointSubnet"]]
      private_endpoint_network_policies = "Enabled"
      service_endpoints                 = ["Microsoft.Storage", "Microsoft.KeyVault"]
    }
    "AVDSubnet" = {
      name             = "AVDSubnet"
      address_prefixes = [module.subnet_addrs.network_cidr_blocks["AVDSubnet"]]

      network_security_group = {
        id = module.avd_subnet_nsg.resource.id
      }
    }
  }

  enable_telemetry = var.telemetry_enabled
}
