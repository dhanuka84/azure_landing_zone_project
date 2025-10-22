// Output Azure Firewall private IP for UDR next-hop consumption
output "azure_firewall_private_ip" {
  description = "Private IP address of the hub Azure Firewall"
  value       = azurerm_firewall.hub.ip_configuration[0].private_ip_address
}
