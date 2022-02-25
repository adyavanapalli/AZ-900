terraform {
  backend "azurerm" {
    container_name       = "terraform"
    key                  = "db.default.tfstate"
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


resource "random_pet" "mssql_database_name" {}
resource "random_pet" "mssql_firewall_rule_name" {}
resource "random_pet" "postgresql_database_name" {}
resource "random_pet" "postgresql_firewall_rule_name" {}
resource "random_pet" "resource_group_name" {}

resource "random_string" "mssql_server_name" {
  length  = 63
  lower   = true
  number  = true
  special = false
  upper   = false
}

resource "random_string" "postgresql_server_name" {
  length  = 63
  lower   = true
  number  = true
  special = false
  upper   = false
}

resource "random_password" "mssql_server_password" {
  length  = 128
  lower   = true
  number  = true
  special = false
  upper   = true
}

resource "random_password" "postgresql_server_password" {
  length  = 128
  lower   = true
  number  = true
  special = false
  upper   = true
}

resource "azurerm_resource_group" "resource_group" {
  location = var.region
  name     = random_pet.resource_group_name.id
}

resource "azurerm_mssql_server" "mssql_server" {
  administrator_login          = var.username
  administrator_login_password = random_password.mssql_server_password.result
  location                     = azurerm_resource_group.resource_group.location
  name                         = random_string.mssql_server_name.id
  resource_group_name          = azurerm_resource_group.resource_group.name
  version                      = "12.0"
}

resource "azurerm_mssql_firewall_rule" "mssql_firewall_rule" {
  end_ip_address   = "255.255.255.255"
  name             = random_pet.mssql_firewall_rule_name.id
  server_id        = azurerm_mssql_server.mssql_server.id
  start_ip_address = "0.0.0.0"
}

resource "azurerm_mssql_database" "mssql_database" {
  max_size_gb          = "1"
  name                 = random_pet.mssql_database_name.id
  server_id            = azurerm_mssql_server.mssql_server.id
  sku_name             = "Basic"
  storage_account_type = "LRS"
}

resource "azurerm_postgresql_server" "postgresql_server" {
  administrator_login          = var.username
  administrator_login_password = random_password.postgresql_server_password.result
  location                     = azurerm_resource_group.resource_group.location
  name                         = random_string.postgresql_server_name.id
  resource_group_name          = azurerm_resource_group.resource_group.name
  sku_name                     = "B_Gen5_1"
  ssl_enforcement_enabled      = true
  version                      = "11"
}

resource "azurerm_postgresql_firewall_rule" "firewall_rule" {
  end_ip_address      = "255.255.255.255"
  name                = random_pet.postgresql_firewall_rule_name.id
  resource_group_name = azurerm_resource_group.resource_group.name
  server_name         = azurerm_postgresql_server.postgresql_server.name
  start_ip_address    = "0.0.0.0"
}

resource "azurerm_postgresql_database" "postgresql_database" {
  charset             = "UTF8"
  collation           = "C"
  name                = random_pet.postgresql_database_name.id
  resource_group_name = azurerm_resource_group.resource_group.name
  server_name         = azurerm_postgresql_server.postgresql_server.name
}
