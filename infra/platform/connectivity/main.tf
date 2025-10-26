module "hub" {
  source              = "../../modules/networking-hub"
  name_prefix         = var.name_prefix
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.0.0.0/16"]
  firewall_cidr       = "10.0.0.0/24"
  gateway_cidr        = "10.0.1.0/24"
  bastion_cidr        = "10.0.2.0/24"
  create_private_dns  = true
  tags                = { environment = "platform" }
}

# Azure Firewall in hub
data "azurerm_subnet" "afw_subnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = module.hub.vnet_name
}

module "firewall" {
  source              = "../../modules/azure-firewall"
  name                = "afw-hub"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = data.azurerm_subnet.afw_subnet.id
  tags                = { environment = "platform", layer = "security" }
}

# NEW: Add mandatory NSG for Azure Bastion Subnet
module "nsg_bastion" {
  source              = "../../modules/nsg-bastion"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = module.hub.bastion_subnet_id
  tags                = { environment = "platform", layer = "security" }
}