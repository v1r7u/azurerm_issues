
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
  name     = "rg-iot-policy-v1r7u-issue"
  location = local.location
}

resource "azurerm_iothub" "iot" {
  name                = "iot-iot-policy-v1r7u-issue"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku {
    name     = "S1"
    capacity = "1"
  }
}

resource "azurerm_iothub_shared_access_policy" "policy" {
  name                = "policy"
  resource_group_name = azurerm_resource_group.rg.name
  iothub_name         = azurerm_iothub.iot.name

  registry_read   = true
  registry_write  = true
  service_connect = true
  device_connect  = false
}
