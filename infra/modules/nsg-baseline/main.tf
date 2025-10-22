variable "name" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }

variable "inbound_allows" {
  type = list(object({
    name                      = string
    priority                  = number
    source_address_prefix     = string
    destination_port_range    = string
    protocol                  = string
  }))
  default = []
}

resource "azurerm_network_security_group" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_rule" "inbound" {
  for_each                    = { for r in var.inbound_allows : r.name => r }
  name                        = each.value.name
  priority                    = each.value.priority
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = each.value.protocol
  source_port_range           = "*"
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.this.name
}

output "id" { value = azurerm_network_security_group.this.id }
