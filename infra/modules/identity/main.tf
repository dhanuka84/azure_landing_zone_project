terraform {
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = ">=3.100.0" }
  }
}
provider "azurerm" { features {} }

variable "name"                { type = string }
variable "location"            { type = string }
variable "resource_group_name" { type = string }

resource "azurerm_user_assigned_identity" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
}

output "client_id"    { value = azurerm_user_assigned_identity.this.client_id }
output "principal_id" { value = azurerm_user_assigned_identity.this.principal_id }
output "id"           { value = azurerm_user_assigned_identity.this.id }
