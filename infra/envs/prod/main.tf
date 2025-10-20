locals {
  spoke_address_space = ["10.10.0.0/16"]
  snet_aks_nodes_cidr = "10.10.1.0/24"
  snet_pe_cidr        = "10.10.2.0/24"
}

module "spoke" {
  source              = "../../modules/networking-spoke"
  location            = var.location
  resource_group_name = var.resource_group_name
  vnet_name           = "vnet-prod-spoke"
  address_space       = local.spoke_address_space
  subnets = {
    "snet-aks-nodes"         = local.snet_aks_nodes_cidr
    "snet-private-endpoints" = local.snet_pe_cidr
  }
  hub_rg_name         = var.hub_rg_name
  hub_vnet_name       = var.hub_vnet_name
  allow_gateway_transit = true
  use_remote_gateways   = true
}

module "acr" {
  source              = "../../modules/acr"
  name                = "acrprodmain"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Premium"
}

module "aks" {
  source              = "../../modules/aks"
  name                = "aks-prod-main"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "aksprod"
  subnet_id           = module.spoke.subnet_ids["snet-aks-nodes"]
  node_count          = 3
  vm_size             = "Standard_DS3_v2"
}

data "azurerm_client_config" "current" {}

module "kv" {
  source              = "../../modules/keyvault"
  name                = "kv-prod-secrets"
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  public_network_access_enabled = false
  purge_protection_enabled     = true
}

module "rbac" {
  source = "../../modules/rbac"
  assignments = [
    {
      scope_id           = module.acr.id
      role_definition    = "AcrPush"
      principal_objectId = var.spn_app_cicd_prod
    },
    {
      scope_id           = module.aks.id
      role_definition    = "Azure Kubernetes Service Cluster User Role"
      principal_objectId = var.spn_app_cicd_prod
    },
    {
      scope_id           = module.kv.id
      role_definition    = "Key Vault Secrets User"
      principal_objectId = var.spn_key_vault_api_prod
    }
  ]
}

module "pe_kv" {
  source              = "../../modules/private-endpoint"
  name                = "pe-kv-prod"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = module.spoke.subnet_ids["snet-private-endpoints"]
  target_resource_id  = module.kv.id
  subresource_names   = ["vault"]
}

module "pe_acr" {
  source              = "../../modules/private-endpoint"
  name                = "pe-acr-prod"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = module.spoke.subnet_ids["snet-private-endpoints"]
  target_resource_id  = module.acr.id
  subresource_names   = ["registry"]
}
