// Example: baseline NSGs for spoke subnets (replace subnet IDs/placeholders)
// Requires the 'infra/modules/nsg-baseline' module to exist in your repo.
module "nsg_app" {
  source              = "../../modules/nsg-baseline"
  name                = "nsg-app-subnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.prod_rg.name

  inbound_allows = [
    // Allow traffic from firewall or known sources only (replace as needed)
    { name="allow-from-firewall-https", priority=200, source_address_prefix="10.0.0.4", destination_port_range="443", protocol="Tcp" }
  ]
}

resource "azurerm_subnet_network_security_group_association" "app_assoc" {
  subnet_id                 = module.networking_spoke.app_subnet_id   // TODO: replace with your actual subnet output
  network_security_group_id = module.nsg_app.id
}

// Repeat for other subnets (e.g., AKS nodepool)
module "nsg_aks_nodes" {
  source              = "../../modules/nsg-baseline"
  name                = "nsg-aks-nodes"
  location            = var.location
  resource_group_name = azurerm_resource_group.prod_rg.name
  inbound_allows = []
}

resource "azurerm_subnet_network_security_group_association" "aks_nodes_assoc" {
  subnet_id                 = module.networking_spoke.aks_nodepool_subnet_id  // TODO: replace with your actual subnet output
  network_security_group_id = module.nsg_aks_nodes.id
}
