locals {
  # FIX: Change from a list ["10.10.0.0/16"] to a single string "10.10.0.0/16"
  spoke_address_space = "10.10.0.0/16" 
  snet_aks_nodes_cidr = "10.10.1.0/24"
  snet_pe_cidr        = "10.10.2.0/24"
}

module "spoke" {
  source              = "../../modules/networking-spoke"
  location            = var.location
  resource_group_name = var.resource_group_name
  name           = "vnet-prod-spoke"
  address_space       = local.spoke_address_space
  subnets = {
    "snet-aks-nodes"         = local.snet_aks_nodes_cidr
    "snet-private-endpoints" = local.snet_pe_cidr
  }
  hub_rg_name         = var.hub_rg_name
  hub_vnet_name       = var.hub_vnet_name
  allow_gateway_transit = true
  use_remote_gateways   = true
  tags                = var.tags
}

module "acr" {
  source              = "../../modules/acr"
  name                = "acrprodmain"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Premium"
  tags                = var.tags
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
  tags                = var.tags
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
  tags                = var.tags
}

module "rbac" {
  source = "../../modules/rbac"
  # FIX: Change from a LIST [] to a MAP {} with unique keys (e.g., "acr_push", "aks_user", "kv_secret_user")
  assignments = {
    "acr_push" = {
      scope_id           = module.acr.id
      role_definition    = "AcrPush"
      principal_objectId = var.spn_app_cicd_prod
    },
    "aks_user" = {
      scope_id           = module.aks.id
      role_definition    = "Azure Kubernetes Service Cluster User Role"
      principal_objectId = var.spn_app_cicd_prod
    },
    "kv_secret_user" = {
      scope_id           = module.kv.id
      role_definition    = "Key Vault Secrets User"
      principal_objectId = var.spn_key_vault_api_prod
    }
  }
  tags = var.tags
}

module "pe_kv" {
  source              = "../../modules/private-endpoint"
  name                = "pe-kv-prod"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = module.spoke.subnet_ids["snet-private-endpoints"]
  target_resource_id  = module.kv.id
  subresource_names   = ["vault"]
  # FIX: Add Private DNS Zone ID for Key Vault
  private_dns_zone_id = data.terraform_remote_state.platform_connectivity.outputs.kv_private_dns_zone_id 
}

module "pe_acr" {
  source              = "../../modules/private-endpoint"
  name                = "pe-acr-prod"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = module.spoke.subnet_ids["snet-private-endpoints"]
  target_resource_id  = module.acr.id
  subresource_names   = ["registry"]
  tags                = var.tags
  private_dns_zone_id = data.terraform_remote_state.platform_connectivity.outputs.acr_private_dns_zone_id
}

# UDR: Default route to Azure Firewall
module "udr_default" {
  source              = "../../modules/udr"
  name                = "rt-prod-default"
  location            = var.location
  resource_group_name = var.resource_group_name
  firewall_private_ip = var.firewall_private_ip
  subnet_ids          = [module.spoke.subnet_ids["snet-aks-nodes"]]
}
