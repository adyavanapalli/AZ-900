terraform {
  backend "azurerm" {
    container_name       = "terraform"
    key                  = "peering.default.tfstate"
    resource_group_name  = "StorageRG"
    storage_account_name = "u1yssvcgp2yddir9pu9v6o81"
  }
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "random_pet" "network_interface_name" {}
resource "random_pet" "resource_group_name" {}
resource "random_pet" "virtual_network_1_name" {}
resource "random_pet" "virtual_network_2_name" {}
resource "random_pet" "virtual_network_peering_1_name" {}
resource "random_pet" "virtual_network_peering_2_name" {}

resource "azurerm_resource_group" "resource_group" {
  name     = random_pet.resource_group_name.id
  location = var.region
}

resource "azurerm_virtual_network" "virtual_network_1" {
  address_space       = ["10.0.0.0/24"]
  name                = random_pet.virtual_network_1_name.id
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_virtual_network" "virtual_network_2" {
  address_space       = ["10.0.1.0/24"]
  name                = random_pet.virtual_network_2_name.id
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_virtual_network_peering" "virtual_network_peering_1" {
  name                      = random_pet.virtual_network_peering_1_name.id
  virtual_network_name      = azurerm_virtual_network.virtual_network_1.name
  remote_virtual_network_id = azurerm_virtual_network.virtual_network_2.id
  resource_group_name       = azurerm_resource_group.resource_group.name
}

resource "azurerm_virtual_network_peering" "virtual_network_peering_2" {
  name                      = random_pet.virtual_network_peering_2_name.id
  virtual_network_name      = azurerm_virtual_network.virtual_network_2.name
  remote_virtual_network_id = azurerm_virtual_network.virtual_network_1.id
  resource_group_name       = azurerm_resource_group.resource_group.name
}
