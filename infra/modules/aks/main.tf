resource "azurerm_kubernetes_cluster" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  default_node_pool {
    name           = "sys"
    vm_size        = var.vm_size
    node_count     = var.node_count
    vnet_subnet_id = var.subnet_id
  }
  identity { type = "SystemAssigned" }
  network_profile { network_plugin = "azure" }
  azure_active_directory_role_based_access_control { managed = true }
}

output "id" { value = azurerm_kubernetes_cluster.this.id }
