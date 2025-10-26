# Fetches the built-in policy definition for "Deny Public IP"
data "azurerm_policy_definition" "deny_public_ip" {
  display_name = "Network interfaces should not have public IPs"
}

# Assigns the policy at the "Platform" Management Group scope
# This enforces the rule on all child subscriptions (Connectivity, NonProd, Prod)
resource "azurerm_management_group_policy_assignment" "deny_public_ip" {
  name                 = "deny-public-ip"
  management_group_id  = azurerm_management_group.platform.id
  policy_definition_id = data.azurerm_policy_definition.deny_public_ip.id
  description          = "Deny creation of Public IP addresses on NICs."
  enforcement_mode     = "Enabled"
}