locals {
  spoke_address_space = "10.10.0.0/16"
  snet_aks_nodes_cidr = "10.10.1.0/24"
  snet_pe_cidr        = "10.10.2.0/24"
  snet_app_gw_cidr    = "10.10.3.0/24" # <-- NEW
  snet_apim_cidr      = "10.10.4.0/24" # <-- NEW
  
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
    },
    "snet-app-gateway" = { # <-- NEW
      address_prefixes = [local.snet_app_gw_cidr]
      associate_default_nsg = false # Opt-out of default NSG
    },
    "snet-apim" = { # <-- NEW
      address_prefixes = [local.snet_apim_cidr]
      associate_default_nsg = false # Opt-out of default NSG
    }
  }
}

# --- NEW NSG MODULES ---
module "nsg_app_gateway" {
  source              = "../../modules/nsg-app-gateway"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

module "nsg_apim" {
  source              = "../../modules/nsg-apim"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
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

  # NEW: Attach the VNet to the DDoS Plan
  ddos_protection_plan_id = data.terraform_remote_state.platform_connectivity.outputs.ddos_protection_plan_id
}

# --- NEW NSG ASSOCIATIONS ---
# Associate the custom NSGs to the new subnets
resource "azurerm_subnet_network_security_group_association" "app_gw" {
  subnet_id                 = module.spoke.subnet_ids["snet-app-gateway"]
  network_security_group_id = module.nsg_app_gateway.id
}

resource "azurerm_subnet_network_security_group_association" "apim" {
  subnet_id                 = module.spoke.subnet_ids["snet-apim"]
  network_security_group_id = module.nsg_apim.id
}

# --- NEW PUBLIC IP FOR APP GATEWAY ---
resource "azurerm_public_ip" "app_gw" {
  name                = "pip-prod-app-gw"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# --- NEW APIM & APP GATEWAY MODULES ---
module "apim" {
  source              = "../../modules/apim" # (You need to create this)
  name                = "apim-prod-main"
  location            = var.location
  resource_group_name = var.resource_group_name
  publisher_name      = "My Company"
  publisher_email     = "admin@company.com"
  sku_name            = "Developer_1" # Start with Developer, use Premium for VNet
  vnet_type           = "Internal"
  subnet_id           = module.spoke.subnet_ids["snet-apim"]
  tags                = var.tags
}

module "app_gateway" {
  source                 = "../../modules/app-gateway"
  name                   = "appgw-prod-main"
  location               = var.location
  resource_group_name    = var.resource_group_name
  subnet_id              = module.spoke.subnet_ids["snet-app-gateway"]
  public_ip_address_id   = azurerm_public_ip.app_gw.id
  ssl_certificate_name   = "my-ssl-cert" # You must add this cert to the AppGW
  apim_gateway_url       = module.apim.gateway_url_hostname # Output from your APIM module
  tags                   = var.tags

  # This points to a secret you will need to create in your Key Vault.
  key_vault_secret_id_ssl_cert = "${module.kv.id}/secrets/appgw-ssl-cert"
}

# NEW: Create the User-Assigned Managed Identity for the application
resource "azurerm_user_assigned_identity" "api" {
  name                = "uami-prod-api-workload"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_user_assigned_identity" "aks_cluster" {
  name                = "uami-prod-aks-cluster"
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

  user_assigned_identity_id = azurerm_user_assigned_identity.aks_cluster.id
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
    # --- Existing assignment for the API workload ---
    "kv_secret_user" = {
      scope              = module.kv.id
      role_definition    = "Key Vault Secrets User"
      principal_objectId = azurerm_user_assigned_identity.api.principal_id
    },

    # --- NEW: Roles for the AKS Cluster UAMI ---
    "aks_vnet_contributor" = {
      scope              = module.spoke.subnet_ids["snet-aks-nodes"]
      role_definition    = "Virtual Network Contributor"
      principal_objectId = azurerm_user_assigned_identity.aks_cluster.principal_id
    },
    "aks_mi_operator" = {
      # This role is assigned at the Resource Group scope
      scope              = var.resource_group_name
      role_definition    = "Managed Identity Operator"
      principal_objectId = azurerm_user_assigned_identity.aks_cluster.principal_id
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