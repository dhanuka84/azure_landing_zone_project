output "vnet_id"   { value = azurerm_virtual_network.hub.id }
output "vnet_name" { value = azurerm_virtual_network.hub.name }
output "rg_name"   { value = var.resource_group_name }

# Modified to output a map of IDs for easier consumption
output "private_dns_zone_ids" {
  value = {
    kv  = try(azurerm_private_dns_zone.kv[0].id, null)
    acr = try(azurerm_private_dns_zone.acr[0].id, null)
  }
}

# New output required by the bastion NSG module
output "bastion_subnet_id" {
  value = azurerm_subnet.bastion.id
}