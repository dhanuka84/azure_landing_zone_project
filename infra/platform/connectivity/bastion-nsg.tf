// AzureBastionSubnet NSG with required service-tag rules
module "nsg_bastion" {
  source              = "../../modules/nsg-baseline"
  name                = "nsg-bastion"
  location            = var.location
  resource_group_name = azurerm_resource_group.hub_rg.name
  inbound_allows = [
    { name="allow-https-internet", priority=100, source_address_prefix="Internet",         destination_port_range="443", protocol="Tcp" },
    { name="allow-https-gwmgr",    priority=110, source_address_prefix="GatewayManager",   destination_port_range="443", protocol="Tcp" },
    { name="allow-probe",          priority=120, source_address_prefix="AzureLoadBalancer",destination_port_range="443", protocol="Tcp" },
    { name="allow-dataplane1",     priority=130, source_address_prefix="VirtualNetwork",   destination_port_range="8080", protocol="Tcp" },
    { name="allow-dataplane2",     priority=131, source_address_prefix="VirtualNetwork",   destination_port_range="5701", protocol="Tcp" }
  ]
}

resource "azurerm_subnet_network_security_group_association" "bastion_assoc" {
  subnet_id                 = azurerm_subnet.azurebastionsubnet.id
  network_security_group_id = module.nsg_bastion.id
}
