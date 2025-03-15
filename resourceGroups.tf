resource "azurerm_resource_group" "avd_rg" {
  name     = "rg-${var.org}-avd-${var.env}-${local.reg}-01"
  location = var.location
}

module "sessionhost_rg" {
  source = "Azure/avm-res-resources-resourcegroup/azurerm"

  name     = "rg-${var.org}-avd-sh-${var.env}-${local.reg}-01"
  location = var.location

  enable_telemetry = var.telemetry_enabled

  role_assignments = { for i, ra in local.sessionHost_rg_all_roles : i => {
    principal_id               = ra.principal_id
    role_definition_id_or_name = ra.role_definition_id_or_name
  } }
}

moved {
  from = azurerm_resource_group.sessionhost_rg
  to   = module.sessionhost_rg.azurerm_resource_group.this
}
