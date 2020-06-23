
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
  name     = "rg-iot-eventhub-v1r7u-issue"
  location = local.location
}

resource "azurerm_iothub" "iot" {
  name                = "iot-eventhub-v1r7u-issue"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku {
    name     = "S1"
    capacity = "1"
  }

  route {
    name           = "defaultroute"
    source         = "DeviceMessages"
    condition      = "true"
    endpoint_names = ["events"]
    enabled        = true
  }
}

resource "azurerm_iothub_shared_access_policy" "telemetry_normalizer" {
  name                = "telemetry_normalizer"
  resource_group_name = azurerm_resource_group.rg.name
  iothub_name         = azurerm_iothub.iot.name

  service_connect = true
}

resource "azurerm_iothub_consumer_group" "normalizer" {
  name                   = "normalizer"
  iothub_name            = azurerm_iothub.iot.name
  eventhub_endpoint_name = "events"
  resource_group_name    = azurerm_resource_group.rg.name
}

resource "azurerm_app_service_plan" "consumption_plan" {
  name                = "iot-eventhub-v1r7u-issue-plan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  kind                = "FunctionApp"

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_storage_account" "func_storage" {
  name                     = replace("iot-eventhub-v1r7u-issue-st", "/[^a-z0-9]/", "")
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_function_app" "functionapp" {
  name                       = "iot-eventhub-v1r7u-issue-func"
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = azurerm_resource_group.rg.location
  app_service_plan_id        = azurerm_app_service_plan.consumption_plan.id
  storage_account_name       = azurerm_storage_account.func_storage.name
  storage_account_access_key = azurerm_storage_account.func_storage.primary_access_key

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    "IoTHub_ConsumerGroup" = azurerm_iothub_consumer_group.normalizer.name
    "IoTHub_CS"            = "Endpoint=${azurerm_iothub.iot.event_hub_events_endpoint};SharedAccessKeyName=${azurerm_iothub_shared_access_policy.telemetry_normalizer.name};SharedAccessKey=${azurerm_iothub_shared_access_policy.telemetry_normalizer.primary_key};EntityPath=${azurerm_iothub.iot.event_hub_events_path}"
  }
}
