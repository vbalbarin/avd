resource "azurerm_resource_group" "sessionhost_rg" {
  name     = "rg-${var.org}-avd-sh-${var.env}-${local.reg}-01"
  location = var.location
}

resource "azurerm_resource_group" "avd_rg" {
  name     = "rg-${var.org}-avd-${var.env}-${local.reg}-01"
  location = var.location
}
