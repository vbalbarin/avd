locals {
  subscription_id = var.spoke_subscription_id
  location        = lower(var.location)
  reg             = var.az_region_abbreviations[var.location]

  subnet_names = {
    AzureFirewallSubnet           = "AzureFirewallSubnet"
    AzureFirewallManagementSubnet = "AzureFirewallManagementSubnet"
    AzureBastionSubnet            = "AzureBastionSubnet"
    DomainControllerSubnet        = "DomainControllerSubnet"
    ComputeSubnet                 = "ComputeSubnet"
  }

  // TODO: Rename these to be more descriptive (e.g. vnet_name, vnet_rg_name, snet_name)
  vnet    = length(var.vnet) != 0 ? var.vnet : "vnet-${var.org}-avd-${var.env}-${local.reg}-01"
  vnet_rg = length(var.vnet_rg) != 0 ? var.vnet_rg : "rg-${var.org}-network-${var.env}-${local.reg}-01"
  snet    = length(var.snet) != 0 ? var.snet : "subnet-sessionhost"

  intuneMdmId = "0000000a-0000-0000-c000-000000000000"
}

