output "location" {
  value       = azurerm_resource_group.network_rg.location
  description = "Azure Resource Group Location"
}

output "rg_name" {
  value       = azurerm_resource_group.network_rg.name
  description = "Azure Resource Group Name"
}

output "rg_id" {
  value       = azurerm_resource_group.network_rg.id
  description = "Azure Resource Group ID"
}

output "vnet_name" {
  value       = module.virtualnetwork.name
  description = "Azure Vnet Name"
}

output "vnet_id" {
  value       = module.virtualnetwork.resource_id
  description = "The ID of the VNet."
}

output "subnet_subnet_id" {
  value = module.virtualnetwork.subnets["AVDSubnet"].resource.output.id
}

/*output "subnet_name" {
  value = azurerm_subnet.subnet.name
}
*/

output "nsg_name" {
  value       = module.avd_subnet_nsg.resource.name
  description = "Azure NSG Name"
}

output "nsg_id" {
  value       = module.avd_subnet_nsg.resource.id
  description = "The ID of the NSG."
}

