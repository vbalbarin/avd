# Configure custom network resources settings
locals {
  conf_network_resources = {

    subscription_id    = var.spoke_subscription_id
    vnet_address_space = var.vnet_address_space
    location           = lower(var.location)
    reg                = var.az_region_abbreviations[var.location]

    # Create a custom tags input
    //tags = var.network_resources_tags
  }
}

