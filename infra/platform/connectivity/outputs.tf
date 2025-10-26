# Output the Firewall's private IP for spokes to consume via remote state
output "firewall_private_ip" {
  value       = module.firewall.private_ip
  description = "The private IP of the central Azure Firewall."
}

# Output the DNS Zone IDs as a map for easy consumption by spokes
output "private_dns_zone_ids" {
  value = {
    "privatelink.vaultcore.azure.net" = module.hub.private_dns_zone_ids["kv"]
    "privatelink.azurecr.io"          = module.hub.private_dns_zone_ids["acr"]
  }
  description = "Map of private DNS zone names to their resource IDs."
}