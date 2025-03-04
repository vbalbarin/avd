locals {
  nsg_rules = {

    "AzureCloud" = {
      access                     = "Allow"
      destination_address_prefix = "AzureCloud"
      destination_port_range     = "8443"
      direction                  = "Outbound"
      name                       = "AzureCloud"
      priority                   = 110
      protocol                   = "Tcp"
      source_address_prefix      = "*"
      source_port_range          = "*"
    }

    "AzureMarketplace" = {
      access                     = "Allow"
      destination_address_prefix = "AzureFrontDoor.Frontend"
      destination_port_range     = "443"
      direction                  = "Outbound"
      name                       = "AzureMarketplace"
      priority                   = 130
      protocol                   = "Tcp"
      source_address_prefix      = "*"
      source_port_range          = "*"
    }

    /*
  "DenyALL" = {
    access                     = "Deny"
    destination_address_prefix = "*"
    destination_port_range     = "*"
    direction                  = "Inbound"
    name                       = "DenyALL"
    priority                   = 4096
    protocol                   = "*"
    source_address_prefix      = "*"
    source_port_range          = "*"
  }
*/
    "WindowsActivation" = {
      access                     = "Allow"
      destination_address_prefix = "Internet"
      destination_port_range     = "1688"
      direction                  = "Outbound"
      name                       = "WindowsActivation"
      priority                   = 140
      protocol                   = "Tcp"
      source_address_prefix      = "*"
      source_port_range          = "*"
    }


    "AzureInstanceMetadata" = {
      access                     = "Allow"
      destination_address_prefix = "169.254.169.254"
      destination_port_range     = "80"
      direction                  = "Outbound"
      name                       = "AzureInstanceMetadata"
      priority                   = 150
      protocol                   = "Tcp"
      source_address_prefix      = "*"
      source_port_range          = "*"
    }

    "AzureMonitor" = {
      access                     = "Allow"
      destination_address_prefix = "AzureMonitor"
      destination_port_range     = "443"
      direction                  = "Outbound"
      name                       = "AzureMonitor"
      priority                   = 120
      protocol                   = "Tcp"
      source_address_prefix      = "*"
      source_port_range          = "*"
    }

    "AVDServiceTraffic" = {
      access                     = "Allow"
      destination_address_prefix = "WindowsVirtualDesktop"
      destination_port_range     = "443"
      direction                  = "Outbound"
      name                       = "AVDServiceTraffic"
      priority                   = 100
      protocol                   = "*"
      source_address_prefix      = "*"
      source_port_range          = "*"
    }

  }
}


module "avd_subnet_nsg" {

  source = "Azure/avm-res-network-networksecuritygroup/azurerm"

  name                = "nsg-${var.org}-avd-${var.env}-${local.conf_network_resources.reg}-01"
  resource_group_name = azurerm_resource_group.network_rg.name
  location            = azurerm_resource_group.network_rg.location

  security_rules = local.nsg_rules

  enable_telemetry = var.telemetry_enabled
}