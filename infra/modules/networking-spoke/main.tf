resource "azurerm_virtual_network" "spoke" {
  # FIX: Changed from var.vnet_name to var.name
  name                = var.name 
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.address_space]
  tags                = var.tags
}

data "azurerm_virtual_network" "hub" {
  name                = var.hub_vnet_name
  resource_group_name = var.hub_rg_name
}

resource "azurerm_subnet" "this" {
  for_each             = var.subnets
  name                 = each.key
  resource_group_name  = azurerm_virtual_network.spoke.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [each.value]
}

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                      = "${azurerm_virtual_network.spoke.name}-to-${var.hub_vnet_name}"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.spoke.name
  remote_virtual_network_id = data.azurerm_virtual_network.hub.id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = var.allow_gateway_transit
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = "${var.hub_vnet_name}-to-${azurerm_virtual_network.spoke.name}"
  resource_group_name       = var.hub_rg_name
  virtual_network_name      = data.azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.spoke.id
  allow_forwarded_traffic   = true
  use_remote_gateways       = var.use_remote_gateways
}