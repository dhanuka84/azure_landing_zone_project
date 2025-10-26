variable "name" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "subnet_id" { type = string }
variable "target_resource_id" { type = string }
variable "subresource_names" { type = list(string) }

# It is now optional because it has a default value.
variable "private_dns_zone_id" {
  type        = string
  description = "The ID of the Private DNS Zone. If null, a DNS record will not be created."
  default     = null
}

variable "tags" {
  type    = map(string)
  default = {}
}