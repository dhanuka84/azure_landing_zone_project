variable "name_prefix" { type = string, default = "" }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "address_space" { type = list(string) }
variable "firewall_cidr" { type = string }
variable "gateway_cidr"  { type = string }
variable "bastion_cidr"  { type = string }
variable "create_private_dns" { type = bool, default = true }
