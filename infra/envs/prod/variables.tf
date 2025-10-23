# File: infra/envs/prod/variables.tf

variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "vnet_address_space" { type = string }
variable "vnet_subnets" { type = map(string) }
variable "hub_rg_name" { type = string }
variable "hub_vnet_name" { type = string }

variable "firewall_private_ip" {
  type    = string
  default = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}

# FIX: Missing variables declared below:
variable "spn_app_cicd_prod" {
  type        = string
  description = "Object ID of the Service Principal for CI/CD operations (e.g., ACR Push, AKS Deployment)."
}

variable "spn_key_vault_api_prod" {
  type        = string
  description = "Object ID of the Service Principal used by the application API to access Key Vault secrets."
}