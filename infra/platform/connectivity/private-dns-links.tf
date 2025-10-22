// Example: link hub VNet to Key Vault private DNS zone
// Repeat / loop for each privatelink zone and for spokes as needed.
resource "azurerm_private_dns_zone_virtual_network_link" "kv_hub" {
  name                  = "kv-hub-link"
  resource_group_name   = azurerm_resource_group.hub_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.kv_pl.name
  virtual_network_id    = azurerm_virtual_network.vnet_hub_weu.id
  registration_enabled  = false
}
