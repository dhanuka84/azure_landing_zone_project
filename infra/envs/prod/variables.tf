variable "location"            { type = string }
variable "resource_group_name" { type = string }
variable "hub_rg_name"         { type = string }
variable "hub_vnet_name"       { type = string }
variable "spn_app_cicd_prod"   { type = string }
variable "spn_key_vault_api_prod" { type = string }
variable "firewall_private_ip" { type = string, default = "" }
variable "tags" { type = map(string), default = {} }
