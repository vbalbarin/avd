resource "azurerm_resource_group" "network_rg" {
  name     = "rg-${var.org}-avd-network-${var.env}-${local.conf_network_resources.reg}-01"
  location = local.conf_network_resources.location
}