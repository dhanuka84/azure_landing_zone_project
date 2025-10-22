locals {
  chosen_principal_id = coalesce(var.principal_id, var.principal_object_id)
}

resource "azurerm_role_assignment" "this" {
  scope                = var.scope_id
  role_definition_name = var.role_definition_name
  principal_id         = local.chosen_principal_id
}
