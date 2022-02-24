terraform {
  backend "azurerm" {
    container_name       = "terraform"
    key                  = "vnet-peering.default.tfstate"
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

resource "random_pet" "network_interface_ip_configuration_1_name" {}
resource "random_pet" "network_interface_ip_configuration_2_name" {}
resource "random_pet" "network_interface_1_name" {}
resource "random_pet" "network_interface_2_name" {}
resource "random_pet" "public_ip_1_name" {}
resource "random_pet" "public_ip_2_name" {}
resource "random_pet" "resource_group_name" {}
resource "random_pet" "subnet_1_name" {}
resource "random_pet" "subnet_2_name" {}
resource "random_pet" "virtual_machine_1_name" {}
resource "random_pet" "virtual_machine_2_name" {}
resource "random_pet" "virtual_network_1_name" {}
resource "random_pet" "virtual_network_2_name" {}
resource "random_pet" "virtual_network_peering_1_name" {}
resource "random_pet" "virtual_network_peering_2_name" {}

// <WARNING>

// One should generally not pass around keys like this and instead generate them
// locally or through some other means or not use keys at all.
resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}
// </WARNING>

resource "azurerm_resource_group" "resource_group" {
  name     = random_pet.resource_group_name.id
  location = var.region
}

resource "azurerm_virtual_network" "virtual_network_1" {
  address_space       = ["10.0.0.0/16"]
  name                = random_pet.virtual_network_1_name.id
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_virtual_network" "virtual_network_2" {
  address_space       = ["10.1.0.0/16"]
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

resource "azurerm_subnet" "subnet_1" {
  address_prefixes     = ["10.0.0.0/24"]
  name                 = random_pet.subnet_1_name.id
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network_1.name
}

resource "azurerm_subnet" "subnet_2" {
  address_prefixes     = ["10.1.0.0/24"]
  name                 = random_pet.subnet_2_name.id
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network_2.name
}

resource "azurerm_public_ip" "public_ip_1" {
  name                = random_pet.public_ip_1_name.id
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "network_interface_1" {
  ip_configuration {
    name                          = random_pet.network_interface_ip_configuration_1_name.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.subnet_1.id
    public_ip_address_id          = azurerm_public_ip.public_ip_1.id
  }
  location            = azurerm_resource_group.resource_group.location
  name                = random_pet.network_interface_1_name.id
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_public_ip" "public_ip_2" {
  name                = random_pet.public_ip_2_name.id
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "network_interface_2" {
  ip_configuration {
    name                          = random_pet.network_interface_ip_configuration_2_name.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.subnet_2.id
    public_ip_address_id          = azurerm_public_ip.public_ip_2.id
  }
  location            = azurerm_resource_group.resource_group.location
  name                = random_pet.network_interface_2_name.id
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_linux_virtual_machine" "virtual_machine_1" {
  admin_ssh_key {
    public_key = tls_private_key.private_key.public_key_openssh
    username   = var.username
  }
  admin_username        = var.username
  location              = azurerm_resource_group.resource_group.location
  name                  = random_pet.virtual_machine_1_name.id
  network_interface_ids = [azurerm_network_interface.network_interface_1.id]
  os_disk {
    caching              = "None"
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
  name                  = random_pet.virtual_machine_2_name.id
  network_interface_ids = [azurerm_network_interface.network_interface_2.id]
  os_disk {
    caching              = "None"
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
