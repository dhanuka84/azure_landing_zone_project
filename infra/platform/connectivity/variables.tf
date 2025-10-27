variable "name_prefix" { type = string, default = "" }
variable "location"    { type = string }
variable "resource_group_name" { type = string }

# NEW: Output the DDoS Plan ID for spokes to consume
output "ddos_protection_plan_id" {
  value       = azurerm_ddos_protection_plan.this.id
  description = "The resource ID of the central DDoS Protection Plan."
}
