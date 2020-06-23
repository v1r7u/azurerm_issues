
terraform {
  required_version = "=0.12.26"
}

provider "azurerm" {
  version = "=2.15.0"
  features {}
}

locals {
  location = "westeurope"
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-dps-v1r7u-issue"
  location = local.location
}

resource "azurerm_iothub" "iot" {
  name                = "iot-dps-v1r7u-issue"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku {
    name     = "S1"
    capacity = "1"
  }
}

resource "azurerm_iothub_shared_access_policy" "dps" {
  name                = "dps"
  resource_group_name = azurerm_resource_group.rg.name
  iothub_name         = azurerm_iothub.iot.name

  registry_read   = true
  registry_write  = true
  service_connect = true
  device_connect  = true
}

resource "azurerm_iothub_dps" "dps" {
  name                = "dps-v1r7u-issue"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku {
    name     = "S1"
    capacity = "1"
  }

  linked_hub {
    connection_string       = azurerm_iothub_shared_access_policy.dps.primary_connection_string
    location                = azurerm_resource_group.rg.location
    apply_allocation_policy = true
    allocation_weight       = 1
  }
}
