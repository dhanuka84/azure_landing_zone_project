// Create a UAMI for the app and grant least-privilege RBAC
module "uami_app_backend" {
  source              = "../../modules/identity"
  name                = "uami-app-backend-api-prod"
  location            = var.location
  resource_group_name = azurerm_resource_group.app_rg.name
}

// Key Vault Secrets User (replace module.kv.id with your KV module output)
module "rbac_kv_secrets_user" {
  source                = "../../modules/rbac"
  principal_id          = module.uami_app_backend.principal_id
  scope_id              = module.kv.id
  role_definition_name  = "Key Vault Secrets User"
}

// ACR pull (replace module.acr.id with your ACR module output)
module "rbac_acr_pull" {
  source                = "../../modules/rbac"
  principal_id          = module.uami_app_backend.principal_id
  scope_id              = module.acr.id
  role_definition_name  = "AcrPull"
}
