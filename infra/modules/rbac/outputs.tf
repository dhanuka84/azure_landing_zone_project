output "ids" { value = [for k, v in azurerm_role_assignment.this : v.id] }
