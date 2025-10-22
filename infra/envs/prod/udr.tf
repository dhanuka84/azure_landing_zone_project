module "spoke_udr" {
  source              = "../../modules/udr"
  name                = "udr-prod-spoke"
  location            = var.location
  resource_group_name = module.networking_spoke.resource_group_name
  tags                = var.tags

  routes = [
    {
      name                   = "default-route"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = data.terraform_remote_state.platform_connectivity.outputs.firewall_private_ip
    }
  ]
}