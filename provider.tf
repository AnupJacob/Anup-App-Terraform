terraform {
  required_providers {
    hcp = {
      source = "hashicorp/hcp"
      version = "0.109.0"
    }
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.42.0"
    }
  }
}

provider "azurerm" {
  resource_provider_registrations = "none" # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "anup-resource-group" {
  name     = "test-resources"
  location = "North Europe"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "example" {
  name                = "anup-test-network"
  resource_group_name = azurerm_resource_group.anup-test-rg.name
  location            = azurerm_resource_group.anup-test-rg.location
  address_space       = ["10.0.0.0/16"]
}