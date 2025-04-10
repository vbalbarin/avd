module "uami" {
  source  = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version = "~> 0.3.3"

  enable_telemetry = var.telemetry_enabled

  location            = azurerm_resource_group.avd_rg.location
  name                = "id-${var.org}-${var.env}-${local.reg}-01"
  resource_group_name = azurerm_resource_group.avd_rg.name
}
