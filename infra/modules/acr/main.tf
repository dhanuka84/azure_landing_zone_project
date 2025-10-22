# Hardened ACR example - wire into your existing attributes as needed
resource "azurerm_container_registry" "this" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = var.sku
  public_network_access_enabled = var.public_network_access_enabled
}
