resource "azurerm_virtual_network" "spoke" {
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

# Create a default NSG for the spoke VNet (can be overridden)
resource "azurerm_network_security_group" "default" {
  name                = "nsg-${var.name}-default"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
  
  security_rule {
    name                       = "AllowVnetInBound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }
  security_rule {
    name                       = "AllowAzureLoadBalancerInBound"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }
  # Add other baseline rules as needed
}

resource "azurerm_subnet" "this" {
  for_each             = var.subnets
  name                 = each.key
  resource_group_name  = azurerm_virtual_network.spoke.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = each.value.address_prefixes

  # NEW: Disable PE network policies on subnets that will host them
  private_endpoint_network_policies_enabled = try(each.value.private_endpoint_network_policies_enabled, true)
}

# NEW: Associate the default NSG with all created subnets
resource "azurerm_subnet_network_security_group_association" "this" {
  for_each                  = azurerm_subnet.this
  subnet_id                 = each.value.id
  network_security_group_id = azurerm_network_security_group.default.id
}

# NEW: Automatically link this spoke VNet to the central Private DNS Zones
resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each              = var.private_dns_zone_ids
  name                  = "link-${var.name}-to-${replace(each.key, ".", "-")}"
  resource_group_name   = var.hub_rg_name # Link is created in the *zone's* RG
  virtual_network_id    = azurerm_virtual_network.spoke.id
  private_dns_zone_name = each.key
}

# ... (VNet peering resources remain unchanged) ...
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