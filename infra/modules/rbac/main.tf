locals { tags = merge({ managed_by = "terraform" }, var.tags) }

resource "azurerm_role_assignment" "this" {
  for_each             = { for i, r in var.assignments : i => r }
  scope                = each.value.scope_id
  role_definition_name = each.value.role_definition
  principal_id         = each.value.principal_objectId
  # Note: azurerm_role_assignment doesn't support tags
}

output "ids" { value = [for k, v in azurerm_role_assignment.this : v.id] }
