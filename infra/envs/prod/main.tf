module "uami_app_backend" {
  source              = "../../modules/identity-uami"
  name                = "uami-app-backend-prod"
  location            = var.location
  resource_group_name = module.networking_spoke.resource_group_name
}

module "kv" {
  source              = "../../modules/keyvault"
  location            = var.location
  resource_group_name = module.networking_spoke.resource_group_name
  name                = "kv-prod"
  tenant_id           = var.tenant_id
}


module "acr" {
  source              = "../../modules/acr"
  location            = var.location
  resource_group_name = module.networking_spoke.resource_group_name
  name                = "acr-prod"
}

module "networking_spoke" {
  source              = "../../modules/networking-spoke"
  location            = var.location
  resource_group_name = "rg-prod-spoke"
  vnet_name           = "vnet-prod"
}

module "nsg_aks" {
  source              = "../../modules/nsg-baseline"
  location            = var.location
  resource_group_name = module.networking_spoke.resource_group_name
  name                = "nsg-aks-prod"
  tags                = var.tags
}