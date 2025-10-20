output "vnet_id"   { value = azurerm_virtual_network.hub.id }
output "vnet_name" { value = azurerm_virtual_network.hub.name }
output "rg_name"   { value = var.resource_group_name }
output "private_dns_ids" {
  value = [
    try(azurerm_private_dns_zone.kv[0].id, null),
    try(azurerm_private_dns_zone.acr[0].id, null)
  ]
}
