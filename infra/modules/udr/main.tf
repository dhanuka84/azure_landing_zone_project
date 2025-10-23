resource "azurerm_route_table" "rt" {
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  # FIX: Replaced deprecated 'disable_bgp_route_propagation = true' 
  bgp_route_propagation_enabled = false 
  tags                          = var.tags

  route {
    name                   = "internet-egress"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.firewall_private_ip
  }
}

resource "azurerm_subnet_route_table_association" "this" {
  for_each       = toset(var.subnet_ids)
  subnet_id      = each.value
  route_table_id = azurerm_route_table.rt.id
}