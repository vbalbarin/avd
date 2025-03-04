terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    azuread = {
      source = "hashicorp/azuread"
    }
    random = {
      source = "hashicorp/random"
    }
    local = {
      source = "hashicorp/local"
    }
    azapi = {
      source = "Azure/azapi"
    }
    time = {
      source = "hashicorp/time"
    }
  }
}

provider "azurerm" {
  subscription_id = var.spoke_subscription_id
  features {
    key_vault {
      purge_soft_deleted_secrets_on_destroy      = false
      purge_soft_deleted_certificates_on_destroy = false
      purge_soft_deleted_keys_on_destroy         = false
      recover_soft_deleted_key_vaults            = true
      recover_soft_deleted_secrets               = true
      recover_soft_deleted_certificates          = true
      recover_soft_deleted_keys                  = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

//provider "azurerm" {
//  features {}
//  alias           = "hub"
//  subscription_id = var.hub_subscription_id
//}

provider "azurerm" {
  features {}
  alias           = "spoke"
  subscription_id = var.spoke_subscription_id
}

//provider "azurerm" {
//  features {}
//  alias           = "avdshared"
//  subscription_id = var.avdshared_subscription_id
//}

//provider "azurerm" {
//  features {}
//  alias           = "identity"
//  subscription_id = var.identity_subscription_id
//}
