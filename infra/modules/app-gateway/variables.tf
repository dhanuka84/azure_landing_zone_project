variable "name" {
  type        = string
  description = "The name of the Application Gateway."
}

variable "location" {
  type        = string
  description = "The Azure region."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group."
}

variable "subnet_id" {
  type        = string
  description = "The subnet ID for the Application Gateway."
}

variable "public_ip_address_id" {
  type        = string
  description = "The ID of the Public IP address to use."
}

variable "ssl_certificate_name" {
  type        = string
  description = "The name of the SSL certificate (which must be added to the AppGW)."
}

variable "apim_gateway_url" {
  type        = string
  description = "The FQDN of the APIM gateway backend (e.q., from module.apim.gateway_url_hostname)."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A map of tags."
}

variable "key_vault_secret_id_ssl_cert" {
  type        = string
  description = "The Key Vault Secret ID for the App Gateway's SSL certificate PFX."
}