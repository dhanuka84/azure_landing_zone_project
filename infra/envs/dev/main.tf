# File: infra/envs/dev/main.tf

module "spoke" {
  source              = "../../modules/networking-spoke"
  location            = var.location
  resource_group_name = var.resource_group_name
  
  # FIX 1: The module variable is 'name', not 'vnet_name'.
  name                = "vnet-dev-spoke" 

  # FIX 2: The module variable 'address_space' expects a string, not a list of strings.
  address_space       = "10.20.0.0/16"

  subnets = {
    "snet-workload"          = "10.20.1.0/24"
    "snet-private-endpoints" = "10.20.2.0/24"
  }
  hub_rg_name         = var.hub_rg_name
  hub_vnet_name       = var.hub_vnet_name
  tags                = var.tags
}

# UDR: Default route to Azure Firewall
module "udr_default" {
  source              = "../../modules/udr"
  name                = "rt-dev-default"
  location            = var.location
  resource_group_name = var.resource_group_name
  firewall_private_ip = var.firewall_private_ip
  subnet_ids          = [module.spoke.subnet_ids["snet-workload"]]
  tags                = var.tags
}