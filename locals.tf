locals {
  subscription_id = var.spoke_subscription_id
  location        = lower(data.azurerm_virtual_network.vnet.location)
  reg             = var.az_region_abbreviations[local.location]

  subnet_names = {
    AzureFirewallSubnet           = "AzureFirewallSubnet"
    AzureFirewallManagementSubnet = "AzureFirewallManagementSubnet"
    AzureBastionSubnet            = "AzureBastionSubnet"
    DomainControllerSubnet        = "DomainControllerSubnet"
    ComputeSubnet                 = "ComputeSubnet"
  }

  intuneMdmId = "0000000a-0000-0000-c000-000000000000"

  all_identities = concat(var.user_assignments, var.admin_assignments)

  sessionHost_rg_user_roles = { for i, oid in var.user_assignments : i => {
    principal_id               = oid
    role_definition_id_or_name = "Virtual Machine User Login"
  } }
  sessionHost_rg_admin_roles = { for i, oid in var.admin_assignments : i + length(var.user_assignments) => {
    principal_id               = oid
    role_definition_id_or_name = "Virtual Machine Administrator Login"
  } }
  sessionHost_rg_all_roles = merge(local.sessionHost_rg_user_roles, local.sessionHost_rg_admin_roles)

  session_host_local_password_secret_name = "${var.vm_name_prefix}password"

  instance_formatted = format("%02d", var.instance)
}

