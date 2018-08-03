variable "name" {
  type = "string"
  default = "azure-container-instance"
}
variable "subscription_id" {}

provider "azurerm" {

}

resource "azurerm_resource_group" "test" {
  name     = "${var.name}"
  location = "centralus"
}

resource "azurerm_storage_account" "test" {
  name                     = "${replace(var.name, "-", "")}"
  resource_group_name      = "${azurerm_resource_group.test.name}"
  location                 = "${azurerm_resource_group.test.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_container_registry" "test" {
  name                = "${replace(var.name, "-", "")}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  location            = "${azurerm_resource_group.test.location}"
  admin_enabled       = true
  sku                 = "Basic"
}

resource "azurerm_application_insights" "test" {
  name                = "${var.name}"
  location            = "South Central US"
  resource_group_name = "${azurerm_resource_group.test.name}"
  application_type    = "Web"
}

resource "azurerm_app_service_plan" "test" {
  name                = "${var.name}"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  kind                = "FunctionApp"

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "test" {
  name                      = "${var.name}"
  location                  = "${azurerm_resource_group.test.location}"
  resource_group_name       = "${azurerm_resource_group.test.name}"
  app_service_plan_id       = "${azurerm_app_service_plan.test.id}"
  storage_connection_string = "${azurerm_storage_account.test.primary_connection_string}"
  https_only = false

  app_settings {
    "APPINSIGHTS_INSTRUMENTATIONKEY" = "${azurerm_application_insights.test.instrumentation_key}"
    "SUBSCRIPTION_ID" = "${var.subscription_id}"
  }
}