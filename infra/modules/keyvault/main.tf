locals { tags = merge({ managed_by = "terraform" }, var.tags) }

resource "azurerm_key_vault" "this" {
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  tenant_id                     = var.tenant_id
  sku_name                      = "standard"
  public_network_access_enabled = var.public_network_access_enabled
  purge_protection_enabled      = var.purge_protection_enabled
  soft_delete_retention_days    = 7
  tags                          = local.tags
}
