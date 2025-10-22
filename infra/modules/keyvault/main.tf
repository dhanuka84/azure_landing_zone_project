# Hardened Key Vault example - align with your existing module
resource "azurerm_key_vault" "this" {
  name                        = var.name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  tenant_id                   = var.tenant_id
  sku_name                    = var.sku_name
  public_network_access_enabled = var.public_network_access_enabled

  purge_protection_enabled    = true
  soft_delete_retention_days  = 90
}
