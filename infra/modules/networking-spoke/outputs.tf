output "aks_subnet_id" {
  value = azurerm_subnet.aks_subnet.id
}

output "app_subnet_id" {
  value = azurerm_subnet.app_subnet.id
}

output "private_endpoint_subnet_id" {
  value = azurerm_subnet.pe_kv_subnet.id
}

output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}