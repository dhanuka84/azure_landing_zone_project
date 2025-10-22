variable "name" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "sku" {
  type    = string
  default = "Premium"
}
variable "public_network_access_enabled" {
  description = "Disable public access by default for Zero Trust"
  type        = bool
  default     = false
}
# Add any other pre-existing variables from your module here.
