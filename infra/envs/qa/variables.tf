# File: infra/envs/qa/variables.tf

variable "location"            { type = string }
variable "resource_group_name" { type = string }
variable "hub_rg_name"         { type = string }
variable "hub_vnet_name"       { type = string }

variable "firewall_private_ip" {
  type    = string
  default = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}