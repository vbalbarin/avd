module "uami" {
  source = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"

  location            = azurerm_resource_group.avd_rg.location
  enable_telemetry    = var.telemetry_enabled
  name                = "id-${var.org}-${var.env}-${local.reg}-01"
  resource_group_name = azurerm_resource_group.avd_rg.name
}
