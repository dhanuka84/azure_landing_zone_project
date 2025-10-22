resource "azurerm_subnet_network_security_group_association" "aks_nodes_assoc" {
  subnet_id                 = module.networking_spoke.aks_subnet_id
  network_security_group_id = module.nsg_aks.id
}