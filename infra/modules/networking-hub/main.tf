locals { tags = merge({ managed_by = "terraform" }, var.tags) }

resource "azurerm_virtual_network" "hub" {
  name                = coalesce(var.name_prefix, "") != "" ? "${var.name_prefix}-vnet-hub-weu" : "vnet-hub-weu"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  tags                = local.tags
}

resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.firewall_cidr]
}
resource "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.gateway_cidr]
}
resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.bastion_cidr]
}

resource "azurerm_private_dns_zone" "kv"  {
  count               = var.create_private_dns ? 1 : 0
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name
  tags                = local.tags
}
resource "azurerm_private_dns_zone" "acr" {
  count               = var.create_private_dns ? 1 : 0
  name                = "privatelink.azurecr.io"
  resource_group_name = var.resource_group_name
  tags                = local.tags
}

output "vnet_name" { value = azurerm_virtual_network.hub.name }
