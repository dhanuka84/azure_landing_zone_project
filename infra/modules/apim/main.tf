resource "azurerm_api_management" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  publisher_name      = var.publisher_name
  publisher_email     = var.publisher_email
  sku_name            = var.sku_name
  tags                = var.tags

  # This section configures APIM for 'Internal' mode
  virtual_network_type = var.vnet_type
  virtual_network_configuration {
    subnet_id = var.subnet_id
  }
}