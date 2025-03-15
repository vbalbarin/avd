module "hostpool" {
  source = "Azure/avm-res-desktopvirtualization-hostpool/azurerm"

  enable_telemetry = var.telemetry_enabled

  virtual_desktop_host_pool_location            = azurerm_resource_group.avd_rg.location
  resource_group_name                           = azurerm_resource_group.avd_rg.name
  virtual_desktop_host_pool_resource_group_name = azurerm_resource_group.avd_rg.name

  virtual_desktop_host_pool_name                     = "vdpool-${var.org}-${var.env}-${local.reg}-01"
  virtual_desktop_host_pool_type                     = "Pooled"
  virtual_desktop_host_pool_load_balancer_type       = "DepthFirst"
  virtual_desktop_host_pool_maximum_sessions_allowed = 2

  #virtual_desktop_host_pool_custom_rdp_properties    = var.virtual_desktop_host_pool_custom_rdp_properties
  #virtual_desktop_host_pool_start_vm_on_connect      = var.virtual_desktop_host_pool_start_vm_on_connect

  #   virtual_desktop_host_pool_scheduled_agent_updates = {
  #     enabled = "true"
  #     schedule = tolist([{
  #       day_of_week = "Sunday"
  #       hour_of_day = 0
  #     }])
  #   }
}

module "appgroup" {
  source = "Azure/avm-res-desktopvirtualization-applicationgroup/azurerm"

  enable_telemetry = var.telemetry_enabled

  virtual_desktop_application_group_default_desktop_display_name = "Default Desktop"
  virtual_desktop_application_group_description                  = "AVD Sandbox"
  virtual_desktop_application_group_friendly_name                = "AVD Sandbox"
  virtual_desktop_application_group_host_pool_id                 = module.hostpool.resource.id
  virtual_desktop_application_group_location                     = azurerm_resource_group.avd_rg.location
  virtual_desktop_application_group_resource_group_name          = azurerm_resource_group.avd_rg.name
  virtual_desktop_application_group_name                         = "vdag-${var.org}-${var.env}-${local.reg}-01"
  virtual_desktop_application_group_type                         = "Desktop"

  # Perform "Desktop Virtualization User" role assignment for all identities (users and admins)
  role_assignments = { for i, oid in local.all_identities : i => {
    principal_id               = oid
    role_definition_id_or_name = "Desktop Virtualization User"
  } }
}

module "workspace" {
  source           = "Azure/avm-res-desktopvirtualization-workspace/azurerm"
  enable_telemetry = var.telemetry_enabled

  resource_group_name                           = azurerm_resource_group.avd_rg.name
  virtual_desktop_workspace_location            = azurerm_resource_group.avd_rg.location
  virtual_desktop_workspace_description         = "AVD Sandbox Workspace"
  virtual_desktop_workspace_resource_group_name = azurerm_resource_group.avd_rg.name
  virtual_desktop_workspace_name                = "vdws-${var.org}-${var.env}-${local.reg}-01"
  virtual_desktop_workspace_friendly_name       = "AVD Sandbox Workspace"
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "workappgrassoc" {
  application_group_id = module.appgroup.resource.id
  workspace_id         = module.workspace.resource.id
}

// TODO: This causes the token to change on every run?
resource "azurerm_virtual_desktop_host_pool_registration_info" "registrationInfo" {
  hostpool_id = module.hostpool.resource.id
  # Generating RFC3339Time for the expiration of the token. 
  expiration_date = timeadd(timestamp(), "48h")
}
