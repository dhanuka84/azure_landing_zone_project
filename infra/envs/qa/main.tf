module "spoke" {
  source              = "../../modules/networking-spoke"
  location            = var.location
  resource_group_name = var.resource_group_name
  vnet_name           = "vnet-qa-spoke"
  address_space       = ["10.30.0.0/16"]
  subnets = {
    "snet-aks-nodes"         = "10.30.1.0/24"
    "snet-private-endpoints" = "10.30.2.0/24"
  }
  hub_rg_name         = var.hub_rg_name
  hub_vnet_name       = var.hub_vnet_name
}

module "acr" {
  source              = "../../modules/acr"
  name                = "acrqamain"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
}
