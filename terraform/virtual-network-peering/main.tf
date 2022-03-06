terraform {
  backend "azurerm" {
    container_name       = "tfstate"
    key                  = "virtual-network-peering.tfstate"
    resource_group_name  = "rg-starsandmanifolds-eastus"
    storage_account_name = "ststarsandmanifoldseastu"
  }
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
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
  name     = "rg-virtual-network-peering-eastus"
}

resource "azurerm_virtual_network" "virtual_network_1" {
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.resource_group.location
  name                = "vnet-virtual-networking-peering-eastus-001"
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_virtual_network" "virtual_network_2" {
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.resource_group.location
  name                = "vnet-virtual-networking-peering-eastus-002"
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_virtual_network_peering" "virtual_network_peering_1" {
  name                      = "peer-virtual-networking-peering-eastus-001"
  remote_virtual_network_id = azurerm_virtual_network.virtual_network_2.id
  resource_group_name       = azurerm_resource_group.resource_group.name
  virtual_network_name      = azurerm_virtual_network.virtual_network_1.name
}

resource "azurerm_virtual_network_peering" "virtual_network_peering_2" {
  name                      = "peer-virtual-networking-peering-eastus-002"
  remote_virtual_network_id = azurerm_virtual_network.virtual_network_1.id
  resource_group_name       = azurerm_resource_group.resource_group.name
  virtual_network_name      = azurerm_virtual_network.virtual_network_2.name
}

resource "azurerm_subnet" "subnet_1" {
  address_prefixes     = ["10.0.0.0/24"]
  name                 = "snet-virtual-networking-peering-eastus-001"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network_1.name
}

resource "azurerm_subnet" "subnet_2" {
  address_prefixes     = ["10.1.0.0/24"]
  name                 = "snet-virtual-networking-peering-eastus-002"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network_2.name
}

resource "azurerm_public_ip" "public_ip_1" {
  allocation_method   = "Dynamic"
  location            = azurerm_resource_group.resource_group.location
  name                = "pip-virtual-networking-peering-eastus-001"
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_network_interface" "network_interface_1" {
  ip_configuration {
    name                          = "nicip-virtual-network-peering-eastus-001"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip_1.id
    subnet_id                     = azurerm_subnet.subnet_1.id
  }
  location            = azurerm_resource_group.resource_group.location
  name                = "nic-virtual-network-peering-eastus-001"
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_public_ip" "public_ip_2" {
  name                = "pip-virtual-networking-peering-eastus-002"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "network_interface_2" {
  ip_configuration {
    name                          = "nicip-virtual-network-peering-eastus-002"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip_2.id
    subnet_id                     = azurerm_subnet.subnet_2.id
  }
  location            = azurerm_resource_group.resource_group.location
  name                = "nic-virtual-network-peering-eastus-002"
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_linux_virtual_machine" "virtual_machine_1" {
  admin_ssh_key {
    public_key = tls_private_key.private_key.public_key_openssh
    username   = var.username
  }
  admin_username        = var.username
  location              = azurerm_resource_group.resource_group.location
  name                  = "vm-virtual-network-peering-eastus-001"
  network_interface_ids = [azurerm_network_interface.network_interface_1.id]
  os_disk {
    caching              = "None"
    name                 = "osdisk-virtual-network-peering-eastus-001"
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

resource "azurerm_linux_virtual_machine" "virtual_machine_2" {
  admin_ssh_key {
    public_key = tls_private_key.private_key.public_key_openssh
    username   = var.username
  }
  admin_username        = var.username
  location              = azurerm_resource_group.resource_group.location
  name                  = "vm-virtual-network-peering-eastus-002"
  network_interface_ids = [azurerm_network_interface.network_interface_2.id]
  os_disk {
    caching              = "None"
    name                 = "osdisk-virtual-network-peering-eastus-002"
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
