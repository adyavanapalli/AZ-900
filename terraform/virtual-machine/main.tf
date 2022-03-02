terraform {
  backend "azurerm" {
    container_name       = "tfstate"
    key                  = "virtual-machine.tfstate"
    resource_group_name  = "rg-terraform-eastus"
    storage_account_name = "stterraformeastus5iolo10"
  }
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    tls = {
      source = "hashicorp/tls"
    }
  }
}

provider "azurerm" {
  features {}
}

// <WARNING>

// One should generally not pass around keys like this and instead generate them
// locally or through some other means or not use keys at all.
resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}
// </WARNING>

resource "azurerm_resource_group" "resource_group" {
  location = "East US"
  name     = "rg-virtual-machine-eastus"
}

resource "azurerm_virtual_network" "virtual_network" {
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.resource_group.location
  name                = "vnet-virtual-machine-eastus"
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_subnet" "subnet" {
  address_prefixes     = ["10.0.0.0/24"]
  name                 = "snet-virtual-machine-eastus"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
}

resource "azurerm_public_ip" "public_ip" {
  allocation_method   = "Dynamic"
  location            = azurerm_resource_group.resource_group.location
  name                = "pip-virtual-machine-eastus"
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_network_interface" "network_interface" {
  ip_configuration {
    name                          = "nicip-virtual-machine-eastus"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
    subnet_id                     = azurerm_subnet.subnet.id
  }
  location            = azurerm_resource_group.resource_group.location
  name                = "nic-virtual-machine-eastus"
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_linux_virtual_machine" "virtual_machine" {
  admin_ssh_key {
    public_key = tls_private_key.private_key.public_key_openssh
    username   = var.username
  }
  admin_username        = var.username
  location              = azurerm_resource_group.resource_group.location
  name                  = "vm-virtual-machine-eastus"
  network_interface_ids = [azurerm_network_interface.network_interface.id]
  os_disk {
    caching              = "None"
    name                 = "osdisk-virtual-machine-eastus"
    storage_account_type = "Standard_LRS"
  }
  resource_group_name = azurerm_resource_group.resource_group.name
  size                = "Standard_B1ls"
  source_image_reference {
    offer     = "0001-com-ubuntu-minimal-impish-daily"
    publisher = "Canonical"
    sku       = "minimal-21_10-daily-gen2"
    version   = "latest"
  }
}
