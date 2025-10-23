locals { tags = merge({ managed_by = "terraform" }, var.tags) }

resource "azurerm_public_ip" "afw_pip" {
  name                = var.public_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

resource "azurerm_firewall" "afw" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "AZFW_VNet"
  sku_tier            = var.sku_tier

  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.subnet_id
    public_ip_address_id = azurerm_public_ip.afw_pip.id
  }

  tags = local.tags
}