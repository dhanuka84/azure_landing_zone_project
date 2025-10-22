// Route all egress via the hub firewall
module "spoke_udr" {
  source          = "../../modules/udr"
  name            = "udr-prod-spoke"
  resource_group  = azurerm_resource_group.prod_rg.name
  location        = var.location
  subnet_ids      = [ azurerm_subnet.app_subnet.id ]

  default_route = {
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VirtualAppliance"
    next_hop_ip    = data.terraform_remote_state.connectivity.outputs.azure_firewall_private_ip
  }
}
