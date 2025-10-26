locals {
  spoke_address_space = "10.10.0.0/16"
  snet_aks_nodes_cidr = "10.10.1.0/24"
  snet_pe_cidr        = "10.10.2.0/24"
  
  # Define subnets using the new module structure
  spoke_subnets = {
    "snet-aks-nodes" = {
      address_prefixes = [local.snet_aks_nodes_cidr]
      private_endpoint_network_policies_enabled = false
    },
    "snet-private-endpoints" = {
      address_prefixes = [local.snet_pe_cidr]
      # This is critical for PEs to function
      private_endpoint_network_policies_enabled = false 
    }
  }
}

module "spoke" {
  source              = "../../modules/networking-spoke"
  location            = var.location
  resource_group_name = var.resource_group_name
  name                = "vnet-prod-spoke"
  address_space       = local.spoke_address_space
  subnets             = local.spoke_subnets # Use new local map
  hub_rg_name         = var.hub_rg_name
  hub_vnet_name       = var.hub_vnet_name
  tags                = var.tags
  
  # NEW: Pass the DNS Zone IDs from the platform state
  private_dns_zone_ids = data.terraform_remote_state.platform_connectivity.outputs.private_dns_zone_ids
}

# NEW: Create the User-Assigned Managed Identity for the application
resource "azurerm_user_assigned_identity" "api" {
  name                = "uami-prod-api-workload"
  location            = var.location
  resource_group_name = var.resource_group_name
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
  tags                = var.tags
  # Note: recommend adding oidc_issuer_enabled=true to the AKS module
  # to allow workloads inside AKS to also use OIDC.
}

module "kv" {
  source              = "../../modules/keyvault"
  name                = "kv-prod-secrets"
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  tags                = var.tags
}

module "rbac" {
  source = "../../modules/rbac"
  assignments = {
    # REMOVED: "acr_push" and "aks_user" roles for the static CI/CD SPN.
    # These are now assigned to the OIDC Service Connection identity
    # in Azure AD, outside of this Terraform state.

    # MODIFIED: Assigns role to the new UAMI, not a static SPN
    "kv_secret_user" = {
      scope              = module.kv.id
      role_definition    = "Key Vault Secrets User"
      principal_objectId = azurerm_user_assigned_identity.api.principal_id
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
  tags                = var.tags
  # Note: private_dns_zone_id is no longer needed here,
  # as the VNet link in the spoke module handles DNS resolution.
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
}


module "udr_default" {
  source              = "../../modules/udr"
  name                = "rt-prod-default"
  location            = var.location
  resource_group_name = var.resource_group_name
  # Get firewall IP from remote state
  firewall_private_ip = data.terraform_remote_state.platform_connectivity.outputs.firewall_private_ip
  subnet_ids          = [module.spoke.subnet_ids["snet-aks-nodes"]]
}