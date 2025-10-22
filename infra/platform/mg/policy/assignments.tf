data "azurerm_management_group" "platform" {
  name = "Platform"
}

data "azurerm_policy_definition" "deny_public_ip" {
  display_name = "Network interfaces should not have public IPs"
}

resource "azurerm_policy_assignment" "deny_public_ip" {
  name                 = "deny-nic-public-ip"
  scope                = data.azurerm_management_group.platform.id
  policy_definition_id = data.azurerm_policy_definition.deny_public_ip.id
  enforcement_mode     = "Default"
}

data "azurerm_policy_definition" "append_tags" {
  display_name = "Append required tags to resource groups"
}

resource "azurerm_policy_assignment" "append_tags" {
  name                 = "append-required-tags"
  scope                = data.azurerm_management_group.platform.id
  policy_definition_id = data.azurerm_policy_definition.append_tags.id
  parameters = jsonencode({
    tagName  = { value = "CostCenter" }
    tagValue = { value = "UNKNOWN" }
  })
}
