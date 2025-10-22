module "rbac_kv_secrets_user" {
  source                = "../../modules/rbac"
  principal_id          = module.uami_app_backend.principal_id
  scope_id              = module.kv.id
  role_definition_name  = "Key Vault Secrets User"
}

module "rbac_acr_push" {
  source                = "../../modules/rbac"
  principal_id          = module.uami_app_backend.principal_id
  scope_id              = module.acr.id
  role_definition_name  = "AcrPush"
}