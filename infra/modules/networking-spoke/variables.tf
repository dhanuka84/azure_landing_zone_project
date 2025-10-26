variable "name" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "address_space" { type = string }

# Modified to be an object map to support new NSG and PE properties
variable "subnets" {
  type = map(object({
    address_prefixes = list(string)
    private_endpoint_network_policies_enabled = optional(bool, false)
  }))
  description = "A map of subnet configurations."
}

variable "hub_rg_name" { type = string }
variable "hub_vnet_name" { type = string }

# NEW: Added to receive the central DNS zone info
variable "private_dns_zone_ids" {
  type        = map(string)
  default     = {}
  description = "Map of Private DNS Zone names to their Resource IDs for VNet linking."
}

variable "allow_gateway_transit" {
  type    = bool
  default = true
}
variable "use_remote_gateways" {
  type    = bool
  default = true
}
variable "tags" {
  type    = map(string)
  default = {}
}