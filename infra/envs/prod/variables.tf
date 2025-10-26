variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "vnet_address_space" { type = string }
variable "vnet_subnets" { type = map(string) } # This can likely be removed if using the new 'locals' block
variable "hub_rg_name" { type = string }
variable "hub_vnet_name" { type = string }

# This variable is no longer a static default,
# it will be populated by the remote state.
variable "firewall_private_ip" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}

# REMOVED: spn_app_cicd_prod
# REMOVED: spn_key_vault_api_prod
# These are replaced by OIDC and UAMI respectively.