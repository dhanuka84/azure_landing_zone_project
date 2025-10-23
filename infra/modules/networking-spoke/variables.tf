variable "name" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "address_space" { type = string }
variable "subnets" { type = map(string) } # name → CIDR
variable "hub_rg_name" { type = string }
variable "hub_vnet_name" { type = string }
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