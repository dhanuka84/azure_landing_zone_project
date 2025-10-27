output "id" {
  value = azurerm_api_management.this.id
}

output "gateway_url_hostname" {
  description = "The FQDN of the APIM gateway for the App Gateway backend."
  value       = azurerm_api_management.this.gateway_url
}