locals {
  tags = merge({ managed_by = "terraform" }, var.tags)
  # This local variable is needed for the conditional A-record
  a_record_name = try(split(".", data.azurerm_private_dns_zone.this[0].name)[0], "*")
}

data "azurerm_private_dns_zone" "this" {
  count = var.private_dns_zone_id != null ? 1 : 0
  
  resource_group_name = split("/", var.private_dns_zone_id)[4]
  name                = split("/", var.private_dns_zone_id)[8]
}

resource "azurerm_private_endpoint" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id
  private_service_connection {
    name                           = "psc-${var.name}"
    private_connection_resource_id = var.target_resource_id
    subresource_names              = var.subresource_names
    is_manual_connection           = false
  }
  tags = local.tags
}


resource "azurerm_private_dns_a_record" "this" {
  # This line tells Terraform to only create this resource if the variable is not null
  count = var.private_dns_zone_id != null ? 1 : 0

  name                = local.a_record_name
  zone_name           = data.azurerm_private_dns_zone.this[0].name
  resource_group_name = data.azurerm_private_dns_zone.this[0].resource_group_name
  ttl                 = 300
  records             = [azurerm_private_endpoint.this.private_service_connection[0].private_ip_address]
}