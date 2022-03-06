terraform {
  backend "azurerm" {
    container_name       = "tfstate"
    key                  = "database.tfstate"
    resource_group_name  = "rg-starsandmanifolds-eastus"
    storage_account_name = "ststarsandmanifoldseastu"
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

resource "random_string" "mssql_server_name" {
  length  = 41
  lower   = true
  number  = true
  special = false
  upper   = false
}

resource "random_string" "mysql_server_name" {
  length  = 41
  lower   = true
  number  = true
  special = false
  upper   = false
}

resource "random_string" "postgresql_server_name" {
  length  = 41
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

resource "random_password" "mysql_server_password" {
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
  location = "East US"
  name     = "rg-database-eastus"
}

resource "azurerm_mssql_server" "mssql_server" {
  administrator_login          = var.username
  administrator_login_password = random_password.mssql_server_password.result
  location                     = azurerm_resource_group.resource_group.location
  name                         = "mssql-database-eastus-${random_string.mssql_server_name.id}"
  resource_group_name          = azurerm_resource_group.resource_group.name
  version                      = "12.0"
}

resource "azurerm_mssql_firewall_rule" "mssql_firewall_rule" {
  end_ip_address   = "255.255.255.255"
  name             = "mssqlfwr-database-eastus"
  server_id        = azurerm_mssql_server.mssql_server.id
  start_ip_address = "0.0.0.0"
}

resource "azurerm_mssql_database" "mssql_database" {
  max_size_gb          = "1"
  name                 = "mssqldb-database-eastus"
  server_id            = azurerm_mssql_server.mssql_server.id
  sku_name             = "Basic"
  storage_account_type = "LRS"
}

resource "azurerm_mysql_server" "mysql_server" {
  administrator_login          = var.username
  administrator_login_password = random_password.mysql_server_password.result
  location                     = azurerm_resource_group.resource_group.location
  name                         = "mysql-database-eastus-${random_string.mysql_server_name.id}"
  resource_group_name          = azurerm_resource_group.resource_group.name
  sku_name                     = "B_Gen5_1"
  ssl_enforcement_enabled      = true
  storage_mb                   = "5120"
  version                      = "8.0"
}

resource "azurerm_mysql_firewall_rule" "mysql_firewall_rule" {
  end_ip_address      = "255.255.255.255"
  name                = "mysqlfwr-database-eastus"
  resource_group_name = azurerm_resource_group.resource_group.name
  server_name         = azurerm_mysql_server.mysql_server.name
  start_ip_address    = "0.0.0.0"
}

resource "azurerm_mysql_database" "mysql_database" {
  charset             = "utf8mb4"
  collation           = "utf8mb4_general_ci"
  name                = "mysqldb-database-eastus"
  resource_group_name = azurerm_resource_group.resource_group.name
  server_name         = azurerm_mysql_server.mysql_server.name
}

resource "azurerm_postgresql_server" "postgresql_server" {
  administrator_login          = var.username
  administrator_login_password = random_password.postgresql_server_password.result
  location                     = azurerm_resource_group.resource_group.location
  name                         = "pgsql-database-eastus-${random_string.postgresql_server_name.id}"
  resource_group_name          = azurerm_resource_group.resource_group.name
  sku_name                     = "B_Gen5_1"
  ssl_enforcement_enabled      = true
  version                      = "11"
}

resource "azurerm_postgresql_firewall_rule" "firewall_rule" {
  end_ip_address      = "255.255.255.255"
  name                = "psqlfwr-database-eastus"
  resource_group_name = azurerm_resource_group.resource_group.name
  server_name         = azurerm_postgresql_server.postgresql_server.name
  start_ip_address    = "0.0.0.0"
}

resource "azurerm_postgresql_database" "postgresql_database" {
  charset             = "UTF8"
  collation           = "C"
  name                = "pgsqldb-database-eastus"
  resource_group_name = azurerm_resource_group.resource_group.name
  server_name         = azurerm_postgresql_server.postgresql_server.name
}
