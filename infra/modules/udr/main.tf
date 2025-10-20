locals { tags = merge({ managed_by = "terraform" }, var.tags) }

resource "azurerm_route_table" "rt" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  disable_bgp_route_propagation = false
  tags = local.tags
}

resource "azurerm_route" "default_to_afw" {
  name                   = "default-to-firewall"
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.rt.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.firewall_private_ip
}

resource "azurerm_subnet_route_table_association" "assoc" {
  for_each       = toset(var.subnet_ids)
  subnet_id      = each.value
  route_table_id = azurerm_route_table.rt.id
}

output "route_table_id" { value = azurerm_route_table.rt.id }
